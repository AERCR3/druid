local event = require("event.event")
local events = require("event.events")
local settings = require("druid.system.settings")
local druid_instance = require("druid.system.druid_instance")
local logger = require("druid.system.druid_logger")

local default_style = require("druid.styles.default.style")


---Druid UI框架的入口点。
---在此创建新的Druid实例并调整Druid设置。
---Druid是一个用于Defold引擎的UI系统，提供了各种GUI组件
---@class druid
local M = {}


---创建一个新的Druid实例用于创建GUI组件。
---这是使用Druid UI系统的最主要入口函数，所有基于Druid的UI界面都需要从此开始创建
---@param context table Druid上下文。通常这是gui_script的self。它会被传递到所有Druid回调中。
---@param style table|nil Druid样式表，用于覆盖此Druid实例的样式参数。
---@return druid.instance druid_instance 新的Druid实例
function M.new(context, style)
	--- 如果还没有设置默认样式，则设置默认样式
	--- 确保所有Druid实例都有基础的样式配置
	if settings.default_style == nil then
		M.set_default_style(default_style)
	end

	--- 调用底层实例创建函数，返回可用的Druid实例
	--- 这个实例将作为创建所有组件的容器和管理器
	return druid_instance.create_druid_instance(context, style)
end

---注册新的外部Druid组件，简化组件创建流程
---此函数为组件创建便捷方法，可以通过druid:new_{name}的方式快速创建自定义组件
---这种方式避免了在每个文件中都需要require组件模块，提高了代码复用性
---例如：注册一个名为"my_button"的组件后，就可以使用druid:new_my_button()来创建
---@param name string 组件名称，将作为druid:new_{name}函数的前缀
---@param module table 包含组件逻辑的Lua表
function M.register(name, module)
	--- 检查模块是否为自定义组件（有元表）
	--- 自定义组件继承自druid.component基类
	local is_custom_component = getmetatable(module) ~= nil
	if is_custom_component then
		--- 对于自定义组件，创建标准的创建函数
		--- 这种方式支持链式调用和标准的组件接口
		druid_instance["new_" .. name] = function(self, ...)
			return druid_instance.new(self, module, ...)
		end
	else
		--- 对于普通模块，创建widget创建函数
		--- 这种方式主要用于GUI模板和节点的组合
		--- 注意：建议直接使用druid_instance:new_widget(module, ...)函数
		druid_instance["new_" .. name] = function(self, template, nodes, ...)
			return druid_instance.new_widget(self, module, template, nodes, ...)
		end
	end
end

---为所有Druid实例设置默认样式。
---样式控制UI组件的外观和行为，包括颜色、尺寸、动画等
---@param style table 默认样式
function M.set_default_style(style)
	settings.default_style = style or {}
end

---为多语言文本组件设置文本获取函数
---此函数实现了Druid的国际化支持，允许UI根据当前语言显示对应的文本内容
---LangText组件会调用此函数来获取本地化后的文本显示
---@param callback fun(text_id: string): string 文本获取函数
--- 接收text_id参数，返回对应的语言文本
--- 如果text_id不存在，应该返回默认文本或text_id本身
function M.set_text_function(callback)
	--- 设置全局文本获取函数，如果没有提供则使用空函数
	settings.get_text = callback or function() end
	--- 触发语言变更事件，通知所有LangText组件更新文本
	--- 这确保了语言切换时所有相关UI都能同步更新
	M.on_language_change()
end

---设置声音播放函数，为组件提供统一的音效播放接口
---Druid系统中的各种组件（如Button、Input等）都会调用此函数来播放音效
---这种方式集中管理UI音效，便于实现音效系统的高级功能（如音量控制、音效切换等）
---@param callback fun(sound_id: string) 声音播放回调函数
--- 接收sound_id参数，根据ID播放对应的音效文件
--- 音效文件应该在sounds目录下，格式为/sound#{sound_id}
function M.set_sound_function(callback)
	--- 设置全局声音播放函数，如果没有提供则使用空函数
	--- 这确保即使没有音效回调也不会导致错误
	settings.play_sound = callback or function() end
end

---初始化窗口事件监听器，启用窗口事件处理功能
---此函数会设置全局的窗口监听器，用于处理应用程序级别的窗口事件
---注意：此调用会覆盖之前的窗口监听器，如果已有其他监听器，请手动调用M.on_window_callback
---典型应用场景：处理窗口大小变化、焦点变化、暂停/恢复等事件
function M.init_window_listener()
	--- 设置窗口监听器，当窗口事件发生时触发对应的事件
	--- window_event参数包含事件类型和相关数据
	window.set_listener(function(_, window_event)
		--- 将窗口事件转发给Druid事件系统
		--- 其他组件可以订阅"druid.window_event"来响应这些事件
		events.trigger("druid.window_event", window_event)
	end)
end

--

---触发语言变更事件，通知所有组件更新多语言内容
---当应用语言设置改变时调用此函数，会触发全局的语言变更事件
---所有包含LangText组件的Druid实例都会收到此事件，并更新显示文本
---这是实现动态语言切换的关键函数
function M.on_language_change()
	--- 触发语言变更全局事件
	--- 所有LangText组件都会监听此事件并重新获取对应语言的文本
	events.trigger("druid.language_change")
end

---@type table<userdata, {path: string, fragment: string, new_widget: event}[]>
local REGISTERED_GUI_WIDGETS = {}

---包装widget组件，使其能够从游戏对象调用
---此函数创建widget的安全副本，将所有方法包装为跨上下文事件
---实现了GUI脚本与游戏对象之间的安全通信机制
---仅顶层函数会被包装，嵌套函数无法从游戏对象访问
---@param widget druid.widget 原始widget组件
---@return druid.widget 包装后的widget组件
local function wrap_widget(widget)
	--- 创建widget的副本，使用新的metatable
	--- __index设置为原始widget，保持接口一致性
	local wrapped_widget = setmetatable({}, { __index = widget })
	--- 获取原始widget的方法表
	local parent_table = getmetatable(widget).__index

	--- 遍历原始widget的所有函数方法
	--- 将每个函数包装为事件，使其能够跨上下文调用
	for key, value in pairs(parent_table) do
		if type(value) == "function" then
			--- 创建事件包装器，调用时会传入原始widget作为第一个参数
			wrapped_widget[key] = event.create(function(_, ...)
				return value(widget, ...)
			end)
		end
	end

	--- 保留widget中已有的event对象
	--- 这些事件对象已经可以在跨上下文中使用
	for key, value in pairs(widget) do
		if event.is_event(value) then
			wrapped_widget[key] = value
		end
	end

	--- 返回包装后的widget
	--- 这个widget可以安全地从游戏对象中调用其方法
	return wrapped_widget
end


---从绑定的Druid GUI实例创建一个widget。
---widget将被创建，所有widget函数都可以从Game Object上下文中调用。
---这允许仅为GUI文件使用`druid_widget.gui_script`，并从Game Object脚本文件调用此widget函数。
---这里的Widget类是GUI场景的lua文件（Druid中的widgets）
---		msg.url(nil, nil, "gui_widget") -- 当前游戏对象
---		msg.url(nil, object_url, "gui_widget") -- 其他游戏对象
---此函数实现了跨脚本的widget通信机制，是Druid架构的重要组成部分
---@generic T: druid.widget
---@param widget_class T 要返回的widget类
---@param gui_url url|string GUI url或靠近当前脚本的组件名称字符串
---@param params any|nil 要传递给widget的init函数的附加参数
---@return T widget 新创建的widget，
function M.get_widget(widget_class, gui_url, params)
	if type(gui_url) == "string" then
		gui_url = msg.url(nil, nil, gui_url)
	end

	gui_url = gui_url or msg.url()
	local registered_druids = REGISTERED_GUI_WIDGETS[gui_url.socket]
	assert(registered_druids, "Druid widget not registered for this game object")

	for index = 1, #registered_druids do
		local druid = registered_druids[index]
		if druid.fragment == gui_url.fragment and druid.path == gui_url.path then
			return druid.new_widget(widget_class, nil, nil, params)
		end
	end

	error("Druid widget not found for this game object: " .. gui_url)
end

---将Druid GUI实例绑定到当前游戏对象。
---此实例现在可以从`druid.get_widget()`函数生成widgets。
---每个游戏对象只能设置一个小部件。
---此函数建立了GUI脚本和游戏对象之间的关联，是实现双向通信的基础
---@param druid druid.instance 要注册的druid实例
function M.register_druid_as_widget(druid)
	local gui_url = msg.url()
	REGISTERED_GUI_WIDGETS[gui_url.socket] = REGISTERED_GUI_WIDGETS[gui_url.socket] or {}
	table.insert(REGISTERED_GUI_WIDGETS[gui_url.socket], {
		path = gui_url.path,
		fragment = gui_url.fragment,
		new_widget = event.create(function(widget_class, template, nodes, params)
			return wrap_widget(druid:new_widget(widget_class, template, nodes, params))
		end),
	})
end

---应在最终销毁druid实例时调用。
---此函数用于清理注册的widget引用，防止内存泄漏
function M.unregister_druid_as_widget()
	local gui_url = msg.url()
	local socket = gui_url.socket
	local path = gui_url.path
	local fragment = gui_url.fragment

	for index = 1, #REGISTERED_GUI_WIDGETS[socket] do
		local gui = REGISTERED_GUI_WIDGETS[socket][index]
		if gui.path == path and gui.fragment == fragment then
			table.remove(REGISTERED_GUI_WIDGETS[socket], index)
			break
		end
	end

	if #REGISTERED_GUI_WIDGETS[socket] == 0 then
		REGISTERED_GUI_WIDGETS[socket] = nil
	end
end

---@param logger_instance druid.logger|table|nil
function M.set_logger(logger_instance)
	logger.set_logger(logger_instance)
end

---@param name string?
---@param level string|nil
---@return druid.logger
function M.get_logger(name, level)
	if not name then
		local current_script_path = debug.getinfo(3).short_src
		local basename = string.match(current_script_path, "([^/\\]+)$")
		basename = string.match(basename, "(.*)%..*$")
		name = basename
	end

	return setmetatable({ name = name, level = level }, { __index = logger })
end

return M
