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
---此函数是使用Druid UI系统的主要入口点
---@param context table Druid上下文。通常这是gui_script的self。它会被传递到所有Druid回调中。
---@param style table|nil Druid样式表，用于覆盖此Druid实例的样式参数。
---@return druid.instance druid_instance 新的Druid实例
function M.new(context, style)
	if settings.default_style == nil then
		M.set_default_style(default_style)
	end

	return druid_instance.create_druid_instance(context, style)
end

---Register a new external Druid component.
---Register component just makes the druid:new_{name} function.
---For example, if you register a component called "my_component", you can create it using druid:new_my_component(...).
---This can be useful if you have your own "basic" components that you don't want to require in every file.
---The default way to create component is `druid_instance:new(component_class, ...)`.
---@param name string Module name
---@param module table Lua table with component
function M.register(name, module)
	local is_custom_component = getmetatable(module) ~= nil
	if is_custom_component then
		druid_instance["new_" .. name] = function(self, ...)
			return druid_instance.new(self, module, ...)
		end
	else
		-- Just for some compatability. But better to use direct druid_instance:new_widget(module, ...) function
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

---为LangText组件设置文本函数。
---此函数用于国际化和本地化支持，根据文本ID返回对应的语言文本
---@param callback fun(text_id: string): string 获取本地化文本的函数
function M.set_text_function(callback)
	settings.get_text = callback or function() end
	M.on_language_change()
end

---设置声音函数，使组件能够播放声音。
---此函数提供了一个统一的声音播放接口，便于管理UI音效
---@param callback fun(sound_id: string) 声音播放回调
function M.set_sound_function(callback)
	settings.play_sound = callback or function() end
end

---将Druid订阅到窗口监听器。这将覆盖之前的
---窗口监听器，因此如果已有监听器，请手动调用M.on_window_callback。
---此功能用于处理应用级别的事件，如失去焦点或返回前台
function M.init_window_listener()
	window.set_listener(function(_, window_event)
		events.trigger("druid.window_event", window_event)
	end)
end

---设置窗口回调以启用Druid窗口事件。
---此函数允许手动触发窗口事件，当有其他窗口监听器时特别有用
---@param window_event constant 来自窗口监听器的事件参数
function M.on_window_callback(window_event)
	events.trigger("druid.window_event", window_event)
end

---当游戏语言更改时调用此函数。
---它将通知所有Druid实例更新lang text组件。
---此函数对于实现动态语言切换功能非常重要
function M.on_language_change()
	events.trigger("druid.language_change")
end

---@type table<userdata, {path: string, fragment: string, new_widget: event}[]>
local REGISTERED_GUI_WIDGETS = {}

---设置一个widget到当前游戏对象。游戏对象可以通过调用`bindings.get_widget`获取widget
---它仅将顶层函数包装为跨上下文事件，因此无法访问嵌套widget函数
---此函数实现了GUI脚本与游戏对象之间的安全通信机制
---@param widget druid.widget
---@return druid.widget
local function wrap_widget(widget)
	-- 创建widget的副本，其中所有函数都被包装在事件中
	-- 这使得可以从游戏对象调用GUI函数
	local wrapped_widget = setmetatable({}, { __index = widget })
	local parent_table = getmetatable(widget).__index

	-- 遍历所有函数并将它们包装在事件中
	for key, value in pairs(parent_table) do
		if type(value) == "function" then
			wrapped_widget[key] = event.create(function(_, ...)
				return value(widget, ...)
			end)
		end
	end

	for key, value in pairs(widget) do
		if event.is_event(value) then
			wrapped_widget[key] = value
		end
	end

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
