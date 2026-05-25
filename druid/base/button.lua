local event = require("event.event")
local const = require("druid.const")
local helper = require("druid.helper")
local component = require("druid.component")

---按钮样式参数。
---您可以在Druid样式表中重写此组件样式参数或创建自己的样式
---这些参数控制按钮的交互行为和视觉反馈
---@class druid.button.style
---@field LONGTAP_TIME number|nil 触发on_hold_callback的最短时间。默认值: 0.4
---@field AUTOHOLD_TRIGGER number|nil 按住时触发按钮释放的最大时间。默认值: 0.8
---@field DOUBLETAP_TIME number|nil 双击之间的时间。默认值: 0.4
---@field on_init fun(self)|nil 初始化回调
---@field on_click fun(self, node)|nil 点击回调
---@field on_click_disabled fun(self, node)|nil 禁用状态点击回调
---@field on_hover fun(self, node, hover_state)|nil 悬停回调
---@field on_mouse_hover fun(self, node, hover_state)|nil 鼠标悬停回调
---@field on_set_enabled fun(self, node, enabled_state)|nil 设置启用状态回调

---基本的Druid输入组件。处理节点上的输入并在触摸事件上提供不同的回调。
---
---### 设置
---使用druid创建按钮: `button = druid:new_button(node_name, callback, [params], [animation_node])`
---其中node_name是GUI场景中的节点名称。您可以使用`node_name`作为输入触发区域，并通过`animation_node`指向另一个节点进行动画
---
---### 注意事项
---- 按钮回调具有以下参数: (self, params, button_instance)
----   - **self** - Druid自身上下文
----   - **params** - 在按钮创建时指定的附加参数
----   - **button_instance** - 按钮本身
---- 您可以在按钮创建时在按钮回调上设置_params_: `druid:new_button("node_name", callback, params)`.
---- 按钮有几个事件，如on_click, on_repeated_click, on_long_click, on_hold_click, on_double_click
---- 如果按下和释放状态之间光标在节点区域外，则不会触发单击事件
---- 按钮可以有键触发器，可以通过键使用: `button:set_key_trigger`
---
---按钮组件是用户界面中最常用的交互元素之一，支持多种交互模式
---@class druid.button: druid.component
---@field on_click event fun(self, custom_args, button_instance)
---@field on_pressed event fun(self, custom_args, button_instance)
---@field on_repeated_click event fun(self, custom_args, button_instance, click_count) Repeated click callback, while holding the button
---@field on_long_click event fun(self, custom_args, button_instance, hold_time) Callback on long button tap
---@field on_double_click event fun(self, custom_args, button_instance, click_amount) Different callback, if tap button 2+ in row
---@field on_hold_callback event fun(self, custom_args, button_instance, press_time) Hold callback, before long_click trigger
---@field on_click_outside event fun(self, custom_args, button_instance)
---@field node node Clickable node
---@field node_id hash Node id
---@field anim_node node Animation node. In default case equals to clickable node
---@field params any Custom arguments for any Button event
---@field hover druid.hover Hover component for this button
---@field click_zone node|nil Click zone node to restrict click area
---@field start_scale vector3 Start scale of the button
---@field start_pos vector3 Start position of the button
---@field disabled boolean Is button disabled
---@field key_trigger hash Key trigger for this button
---@field style table Style for this button
local M = component.create("button")


---按钮组件的构造函数
---初始化按钮实例，设置其节点、回调函数、动画节点和事件系统
---这是使用按钮组件时调用的第一个方法，完成了按钮的基础配置
---@param node_or_node_id node|string GUI节点名称或节点对象
--- 用于定义按钮的点击触发区域
---@param callback fun()|nil 按钮点击事件的回调函数
--- 当用户点击按钮时触发，接收(self, params, button_instance)参数
---@param custom_args any|nil 自定义参数，将传递给所有按钮事件的回调函数
--- 可以是任意类型的数据，用于在回调中访问特定信息
---@param anim_node node|string|nil 动画目标节点
--- 如果指定，动画效果将在此节点上播放而不是在触发节点上
--- 适用于在大按钮上动画小图标等场景
function M:init(node_or_node_id, callback, custom_args, anim_node)
	--- 获取Druid实例，用于创建内部组件
	self.druid = self:get_druid()
	--- 获取按钮的GUI节点和ID，用于节点操作和事件处理
	self.node = self:get_node(node_or_node_id)
	self.node_id = gui.get_id(self.node)

	--- 设置动画目标节点，如果未指定则使用触发节点本身
	self.anim_node = anim_node and self:get_node(anim_node) or self.node
	--- 保存节点的初始缩放和位置，用于动画效果和恢复状态
	self.start_scale = gui.get_scale(self.anim_node)
	self.start_pos = gui.get_position(self.anim_node)
	--- 保存自定义参数，供所有按钮事件使用
	self.params = custom_args

	--- 创建悬停检测组件，处理鼠标/触摸悬停状态
	self.hover = self.druid:new_hover(node_or_node_id, self.button_hover)
	self.hover.on_mouse_hover:subscribe(self.button_mouse_hover)

	--- 初始化按钮状态变量
	self.click_zone = nil           -- 自定义点击区域，用于精确控制点击范围
	self.is_repeated_started = false -- 是否已开始重复点击检测
	self.last_pressed_time = 0      -- 最后一次按下时间，用于计算按住时长
	self.last_released_time = 0     -- 最后一次释放时间，用于双击检测
	self.click_in_row = 0           -- 连续点击次数，用于重复点击和双击检测
	self.key_trigger = nil          -- 键盘触发器，用于键盘事件支持

	--- 初始化功能相关变量
	self._check_function = nil         -- 自定义检查函数，用于按钮可用性验证
	self._failure_callback = nil       -- 检查失败时的回调函数
	self._is_html5_mode = false        -- HTML5特殊模式标志
	self._is_html5_listener_set = false -- HTML5监听器设置状态

	--- 创建各种按钮事件，支持多种交互模式
	self.on_click = event.create(callback) -- 普通点击事件
	self.on_pressed = event.create()       -- 按下事件（手部按下时触发）
	self.on_repeated_click = event.create() -- 重复点击事件（按住不放时连续触发）
	self.on_long_click = event.create()    -- 长按事件（按住超过指定时间）
	self.on_double_click = event.create()  -- 双击事件（快速连续点击两次）
	self.on_hold_callback = event.create() -- 按住回调（长按触发前调用）
	self.on_click_outside = event.create() -- 点击外部事件（点击按钮区域外时触发）
end

---私有方法：处理按钮样式变化
---当组件的样式配置发生改变时调用此方法，更新按钮的行为和视觉反馈
---@private
---@param style druid.button.style 新的样式配置表
--- 包含时间阈值、回调函数等配置项
function M:on_style_change(style)
	--- 合并用户自定义样式与默认样式
	self.style = {
		--- 长按触发的最短时间（秒），默认0.4秒
		LONGTAP_TIME = style.LONGTAP_TIME or 0.4,
		--- 长按自动触发的最大时间（秒），默认0.8秒
		--- 超过此时间将触发on_long_click而不是on_hold_callback
		AUTOHOLD_TRIGGER = style.AUTOHOLD_TRIGGER or 0.8,
		--- 双击之间的最大时间间隔（秒），默认0.4秒
		DOUBLETAP_TIME = style.DOUBLETAP_TIME or 0.4,

		--- 各类事件的回调函数，如果未提供则使用默认空函数
		on_init = style.on_init or function() end,                           -- 样式初始化回调
		on_click = style.on_click or function(_, node) end,                  -- 点击时的动画回调
		on_click_disabled = style.on_click_disabled or function(_, node) end, -- 禁用状态点击回调
		on_mouse_hover = style.on_mouse_hover or function(_, node, state) end, -- 鼠标悬停回调
		on_hover = style.on_hover or function(_, node, state) end,           -- 悬停状态回调
		on_set_enabled = style.on_set_enabled or function(_, node, state) end, -- 启用状态变化回调
	}

	--- 调用样式初始化回调，允许样式执行额外的初始化逻辑
	self.style.on_init(self)
end

---禁用按钮的所有样式动画效果
---当不需要按钮的默认动画反馈时，调用此函数可以完全移除视觉动画
---这有助于性能优化或实现自定义的动画系统
---@return druid.button self 当前按钮实例，支持链式调用
function M:set_animations_disabled()
	--- 创建空函数替换所有动画回调
	--- 这样样式相关的动画事件将不再执行任何操作
	local empty_function = function() end

	--- 禁用所有视觉反馈相关的样式回调
	--- 按钮点击、悬停、鼠标悬停、启用状态变化、禁用状态点击都将无动画效果
	self.style.on_click = empty_function         -- 点击动画
	self.style.on_hover = empty_function         -- 悬停动画
	self.style.on_mouse_hover = empty_function   -- 鼠标悬停动画
	self.style.on_set_enabled = empty_function   -- 启用状态动画
	self.style.on_click_disabled = empty_function -- 禁用状态点击动画

	return self
end

---私有方法：后期初始化
---在GUI树完全构建和组件初始化完成后调用此方法
---用于设置点击区域和执行其他需要在组件完全可用后才进行的初始化操作
---@private
function M:on_late_init()
	--- 检查是否设置了自定义点击区域
	--- 如果没有设置，则自动查找最近的遮罩节点作为点击区域
	--- 这确保了按钮在遮罩容器中能正确响应点击
	if not self.click_zone then
		--- 获取按钮节点最近的遮罩节点
		--- 遮罩节点定义了可见区域，按钮的点击应该被限制在此区域内
		local stencil_node = helper.get_closest_stencil_node(self.node)
		if stencil_node then
			--- 将找到的遮罩节点设置为按钮的点击区域
			--- 这防止了用户点击遮罩外的无效区域
			self:set_click_zone(stencil_node)
		end
	end
end

---私有方法：处理输入事件
---这是按钮的核心事件处理函数，负责处理所有类型的输入事件
---包括触摸、鼠标、键盘输入，并根据事件状态触发相应的按钮行为
---@private
---@param action_id hash 输入动作的哈希ID（如ACTION_TOUCH、ACTION_MULTITOUCH等）
---@param action table 输入动作的详细数据，包含位置、状态等信息
---@return boolean is_consumed 是否消耗此输入事件
--- true表示输入已被处理，false表示输入未被处理
function M:on_input(action_id, action)
	--- 检查输入类型是否匹配按钮支持的事件
	--- 只处理触摸/鼠标事件和键盘触发器事件
	if not self:_is_input_match(action_id) then
		return false
	end

	--- 检查按钮节点是否启用（包括父节点）
	--- 如果按钮被禁用，则不处理任何输入事件
	if not gui.is_enabled(self.node, true) then
		return false
	end

	--- 初始化输入处理标志
	local is_consume = true                               -- 默认消耗输入事件
	local is_pick = true                                  -- 默认检测到点击
	local is_key_trigger = (action_id == self.key_trigger) -- 是否为键盘触发

	--- 如果不是键盘触发，则进行点击区域检测
	if not is_key_trigger then
		--- 检测点击位置是否在按钮的有效区域内
		--- click_zone用于限制点击范围，特别是在遮罩或滚动容器中
		is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)
	end

	--- 处理点击按钮外部的情况
	if not is_pick then
		--- 重置交互状态，表示不能与按钮交互
		self.can_action = false
		--- 如果手指/鼠标释放且点击在按钮外部，触发点击外部事件
		if action.released then
			self.on_click_outside:trigger(self:get_context(), self.params, self)
		end

		--- 如果是HTML5模式且设置了HTML5监听器，则清理监听器
		--- 避免内存泄漏和事件重复触发
		if self._is_html5_mode and self._is_html5_listener_set then
			self._is_html5_listener_set = false
			html5.set_interaction_listener(nil)
		end
		return false
	end

	--- 处理键盘触发事件
	if is_key_trigger then
		--- 更新悬停状态，键盘按下时显示悬停效果
		self.hover:set_hover(not action.released)
		--- 键盘事件通常不消耗输入，允许其他组件也处理
		is_consume = false
	end

	--- 处理按下事件（手指/鼠标按下）
	if action.pressed then
		--- 开始新的交互会话
		self.can_action = true                  -- 允许交互
		self.is_repeated_started = false        -- 重置重复点击状态
		self.last_pressed_time = socket.gettime() -- 记录按下时间

		--- 触发按下事件，告知按钮被按下
		self.on_pressed:trigger(self:get_context(), self.params, self)

		--- 如果是HTML5模式，设置交互监听器处理特殊功能
		--- 如复制粘贴、显示键盘等Web特殊功能
		if self._is_html5_mode then
			self._is_html5_listener_set = true
			html5.set_interaction_listener(function()
				self:button_click()
			end)
		end
		return is_consume
	end

	--- 处理重复点击事件（按住不放时连续触发）
	--- 重复触发的速率由input.repeat_interval控制
	if action.repeated then
		--- 只有启用了重复点击事件且正在交互时才触发
		if not self.on_repeated_click:is_empty() and self.can_action then
			self:button_repeated_click()
			return is_consume
		end
	end

	--- 处理释放事件（手指/鼠标抬起）
	if action.released then
		--- 调用内部按钮释放处理逻辑
		--- 这个函数负责判断是普通点击、长按还是双击
		return self:_on_button_release() and is_consume
	end

	--- 处理长按或按住事件
	--- 只有在启用了长按或按住回调时才执行此逻辑
	if self.can_action and (not self.on_long_click:is_empty() or not self.on_hold_callback:is_empty()) then
		--- 计算当前按住时间
		local press_time = socket.gettime() - self.last_pressed_time

		--- 检查是否达到长按自动触发的条件
		--- 如果设置了AUTOHOLD_TRIGGER且达到时间，则自动处理
		if not self.on_long_click:is_empty() and self.style.AUTOHOLD_TRIGGER <= press_time then
			--- 自动触发按钮释放处理
			self:_on_button_release()
			return is_consume
		end

		--- 检查是否达到长按触发时间
		if press_time >= self.style.LONGTAP_TIME then
			--- 触发按住回调（长按触发前调用）
			self:button_hold(press_time)
			return is_consume
		end
	end

	--- 返回处理结果：按钮未禁用且消耗输入
	return not self.disabled and is_consume
end

---私有方法：处理输入中断事件
---当输入事件被其他组件消耗或中断时调用此方法
---用于清理按钮状态，防止输入冲突和状态不一致
---@private
---@param action_id hash 输入动作的哈希ID
---@param action table 输入动作的详细数据
function M:on_input_interrupt(action_id, action)
	--- 重置交互状态，防止按钮保持活动状态
	self.can_action = false
	--- 清除悬停状态，确保视觉反馈正确
	self.hover:set_hover(false)
	self.hover:set_mouse_hover(false)

	--- 检查是否是触摸/鼠标输入事件
	--- 只有这些事件才可能触发点击外部事件
	local is_input_match = self:_is_input_match(action_id) and action.x
	--- 检查按钮是否启用
	local is_enabled = gui.is_enabled(self.node, true)
	--- 如果是有效的输入且按钮启用，检查点击位置
	if is_input_match and is_enabled then
		--- 检测点击是否在按钮的有效区域内
		local is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)
		--- 如果点击在按钮外部且是释放事件，触发点击外部事件
		if not is_pick and action.released then
			self.on_click_outside:trigger(self:get_context(), self.params, self)
		end
	end
end

---设置按钮的启用状态
---调用此方法可以启用或禁用按钮，禁用状态的按钮无法接收任何输入事件
---状态改变时会触发样式的on_set_enabled回调，提供视觉反馈
---@param state boolean|nil 按钮的启用状态
--- true表示启用，false表示禁用，nil表示使用默认状态
---@return druid.button self 当前按钮实例，支持链式调用
function M:set_enabled(state)
	--- 设置禁用标志状态（取反是因为disabled字段名称）
	self.disabled = not state
	--- 同步设置悬停组件的启用状态，保持状态一致性
	self.hover:set_enabled(state)
	--- 调用样式回调，提供启用状态变化的视觉反馈
	self.style.on_set_enabled(self, self.node, state)

	return self
end

---获取按钮的当前启用状态
---通过检查disabled字段来返回按钮是否可交互的状态
---@return boolean is_enabled 如果按钮当前已启用则返回true，否则返回false
--- 按钮启用时可以接收点击和其他交互事件
function M:is_enabled()
	--- 返回启用状态（取反是因为disabled字段名称）
	return not self.disabled
end

---设置按钮的自定义点击区域
---此方法允许精确控制按钮的有效点击范围，特别适用于复杂场景
---比如遮罩容器、滚动视图中的按钮，或需要限制点击范围的UI元素
---@param zone node|string|nil 指定点击区域的GUI节点
--- 可以是节点对象或节点名称字符串
--- 如果为nil，则清除自定义点击区域设置
---@return druid.button self 当前按钮实例，支持链式调用
function M:set_click_zone(zone)
	--- 如果提供了区域节点，则获取节点对象；否则设为nil
	self.click_zone = zone and self:get_node(zone) or nil
	--- 同步设置悬停组件的点击区域，保持交互一致性
	self.hover:set_click_zone(zone)

	return self
end

---设置键盘触发器，允许通过键盘按键触发按钮事件
---此方法使按钮可以通过键盘交互，支持键盘快捷键和无障碍访问
---可以同时设置字符串格式的键名和哈希值的键触发器
---@param key hash|string 键盘输入键的动作ID
--- 可以是字符串格式（如"key_space"、"key_return"）
--- 也可以是已经哈希化的键值
---@return druid.button self 当前按钮实例，支持链式调用
function M:set_key_trigger(key)
	--- 根据输入类型设置键盘触发器
	--- 如果是字符串，转换为哈希值；如果是哈希值，直接使用
	if type(key) == "string" then
		self.key_trigger = hash(key)
	else
		self.key_trigger = key
	end

	return self
end

---获取当前按钮的键盘触发器
---返回用于触发此按钮的键盘输入键的动作ID
---如果没有设置键盘触发器，则返回nil
---@return hash key_trigger 键盘输入键的动作ID
--- 可以用于检查当前按钮绑定的键盘按键
function M:get_key_trigger()
	--- 返回键盘触发器的哈希值
	return self.key_trigger
end

---设置按钮点击可用性的自定义检查函数
---此方法允许在按钮点击前执行条件检查，实现动态的按钮可用性控制
---例如：网络状态检查、游戏逻辑验证、权限验证等场景
---@param check_function function|nil 自定义检查函数
--- 应返回true或false的函数
--- true表示按钮可以正常点击，false表示按钮被禁止点击
---@param failure_callback function|nil 检查失败时的回调函数
--- 当check_function返回false时，会调用此回调函数
--- 可以用于显示错误提示、重试逻辑等处理
---@return druid.button self 当前按钮实例，支持链式调用
function M:set_check_function(check_function, failure_callback)
	--- 保存自定义检查函数和失败回调函数
	self._check_function = check_function
	self._failure_callback = failure_callback

	return self
end

---启用HTML5特殊交互模式
---此模式为Web平台提供特殊的用户交互功能支持
---包括复制粘贴、移动键盘显示、浏览器集成等受保护的Web功能
---在非HTML5环境中，此模式不会被启用
---@param is_web_mode boolean|nil 是否启用HTML5模式
--- true启用HTML5特殊交互模式，false或nil禁用此模式
---@return druid.button self 当前按钮实例，支持链式调用
function M:set_web_user_interaction(is_web_mode)
	--- 启用HTML5模式需要同时满足两个条件：
	--- 1. 用户明确启用了此模式
	--- 2. 当前运行环境是HTML5（html5对象存在）
	--- 使用双重not确保返回布尔值
	self._is_html5_mode = not not (is_web_mode and html5)
	return self
end

---私有方法：检查输入动作是否匹配按钮支持的事件
---此方法用于判断输入事件是否应该被当前按钮处理
---支持触摸事件、鼠标事件和键盘触发器事件
---@param action_id hash 输入动作的哈希ID
--- 来自Defold输入系统的动作标识符
---@return boolean is_match 如果输入与按钮匹配则返回true
--- 返回true表示应该处理此输入，false表示不处理
function M:_is_input_match(action_id)
	--- 检查是否为触摸或多点触摸事件
	--- 这是按钮最基础的输入支持
	if action_id == const.ACTION_TOUCH or action_id == const.ACTION_MULTITOUCH then
		return true
	end

	--- 检查是否为键盘触发事件
	--- 如果设置了键盘触发器且输入动作ID匹配
	if self.key_trigger and action_id == self.key_trigger then
		return true
	end

	--- 既不是触摸/鼠标事件，也不是键盘触发器事件
	return false
end

---调用按钮样式的on_hover回调
---@param hover_state boolean 如果悬停状态处于活动状态则为true
function M:button_hover(hover_state)
	self.style.on_hover(self, self.anim_node, hover_state)
end

---调用按钮样式的on_hover回调
---@param hover_state boolean 如果悬停状态处于活动状态则为true
function M:button_mouse_hover(hover_state)
	self.style.on_mouse_hover(self, self.anim_node, hover_state)
end

---调用按钮点击回调
function M:button_click()
	if self._is_html5_mode then
		self._is_html5_listener_set = false
		html5.set_interaction_listener(nil)
	end
	self.can_action = false
	self.click_in_row = 1
	self.on_click:trigger(self:get_context(), self.params, self)
	self.style.on_click(self, self.anim_node)
end

---调用按钮重复点击回调
function M:button_repeated_click()
	if not self.is_repeated_started then
		self.click_in_row = 0
		self.is_repeated_started = true
	end

	self.click_in_row = self.click_in_row + 1
	self.on_repeated_click:trigger(self:get_context(), self.params, self, self.click_in_row)
	self.style.on_click(self, self.anim_node)
end

---调用按钮长按回调
function M:button_long_click()
	self.click_in_row = 1
	local time = socket.gettime() - self.last_pressed_time
	self.on_long_click:trigger(self:get_context(), self.params, self, time)
	self.style.on_click(self, self.anim_node)
end

---调用按钮双击回调
function M:button_double_click()
	self.click_in_row = self.click_in_row + 1
	self.on_double_click:trigger(self:get_context(), self.params, self, self.click_in_row)
	self.style.on_click(self, self.anim_node)
end

---触发按钮按住回调
---此方法在长按触发之前调用，提供按住过程中的实时反馈
---可以用于显示进度条、改变按钮状态等交互增强功能
---@param press_time number 按钮被持续按住的时间（秒）
--- 从按下到当前时刻的时间间隔
function M:button_hold(press_time)
	--- 触发按住回调事件，传递上下文、自定义参数、按钮实例和按住时间
	self.on_hold_callback:trigger(self:get_context(), self.params, self, press_time)
end

function M:_on_button_release()
	if self.is_repeated_started then
		return false
	end

	local check_function_result = true
	if self._check_function then
		check_function_result = self._check_function(self:get_context())
	end

	if self.disabled then
		if self.can_action then
			self.style.on_click_disabled(self, self.anim_node)
		end
		return true
	elseif not check_function_result then
		if self._failure_callback then
			self._failure_callback(self:get_context())
		end
		return true
	else
		if self.can_action and not self._is_html5_mode then
			self.can_action = false

			local time = socket.gettime()
			local press_time = time - self.last_pressed_time
			local is_long_click = press_time >= self.style.LONGTAP_TIME and not self.on_long_click:is_empty()
			local is_hold_only = press_time >= self.style.LONGTAP_TIME and self.on_long_click:is_empty() and
					not self.on_hold_callback:is_empty()

			local is_double_click = (time - self.last_released_time) < self.style.DOUBLETAP_TIME
			is_double_click = is_double_click and not self.on_double_click:is_empty()

			if is_hold_only then
				return true
			elseif is_long_click then
				local is_hold_complete = (time - self.last_pressed_time) >= self.style.AUTOHOLD_TRIGGER
				if is_hold_complete then
					self:button_long_click()
				else
					self.on_click_outside:trigger(self:get_context(), self.params, self)
				end
			elseif is_double_click then
				self:button_double_click()
			else
				self:button_click()
			end

			self.last_released_time = time
		end
		return true
	end
end

return M
