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
---初始化按钮实例，设置其节点、回调函数和动画节点
---@param node_or_node_id node|string 节点名称或GUI节点本身
---@param callback fun()|nil 按钮点击回调
---@param custom_args any|nil 任何按钮事件的自定义参数，将传递给回调
---@param anim_node node|string|nil 用于动画的节点而不是触发节点，适用于在大面板上动画小图标
function M:init(node_or_node_id, callback, custom_args, anim_node)
	self.druid = self:get_druid()
	self.node = self:get_node(node_or_node_id)
	self.node_id = gui.get_id(self.node)

	self.anim_node = anim_node and self:get_node(anim_node) or self.node
	self.start_scale = gui.get_scale(self.anim_node)
	self.start_pos = gui.get_position(self.anim_node)
	self.params = custom_args
	self.hover = self.druid:new_hover(node_or_node_id, self.button_hover)
	self.hover.on_mouse_hover:subscribe(self.button_mouse_hover)
	self.click_zone = nil
	self.is_repeated_started = false
	self.last_pressed_time = 0
	self.last_released_time = 0
	self.click_in_row = 0
	self.key_trigger = nil

	self._check_function = nil
	self._failure_callback = nil
	self._is_html5_mode = false
	self._is_html5_listener_set = false

	-- Events
	self.on_click = event.create(callback)
	self.on_pressed = event.create()
	self.on_repeated_click = event.create()
	self.on_long_click = event.create()
	self.on_double_click = event.create()
	self.on_hold_callback = event.create()
	self.on_click_outside = event.create()
end

---内部方法：处理样式变化
---当按钮样式发生变化时调用此私有方法
---@private
---@param style druid.button.style 样式配置
function M:on_style_change(style)
	self.style = {
		LONGTAP_TIME = style.LONGTAP_TIME or 0.4,
		AUTOHOLD_TRIGGER = style.AUTOHOLD_TRIGGER or 0.8,
		DOUBLETAP_TIME = style.DOUBLETAP_TIME or 0.4,

		on_init = style.on_init or function() end,
		on_click = style.on_click or function(_, node) end,
		on_click_disabled = style.on_click_disabled or function(_, node) end,
		on_mouse_hover = style.on_mouse_hover or function(_, node, state) end,
		on_hover = style.on_hover or function(_, node, state) end,
		on_set_enabled = style.on_set_enabled or function(_, node, state) end,
	}

	self.style.on_init(self)
end

---移除默认按钮样式动画
---当不需要按钮的默认动画效果时，调用此函数可以完全禁用样式动画
---@return druid.button self 当前按钮实例
function M:set_animations_disabled()
	local empty_function = function() end

	self.style.on_click = empty_function
	self.style.on_hover = empty_function
	self.style.on_mouse_hover = empty_function
	self.style.on_set_enabled = empty_function
	self.style.on_click_disabled = empty_function

	return self
end

---内部方法：后期初始化
---在组件完全初始化后设置点击区域，如果没有明确设置点击区域，则自动查找最近的遮罩节点
---@private
function M:on_late_init()
	if not self.click_zone then
		local stencil_node = helper.get_closest_stencil_node(self.node)
		if stencil_node then
			self:set_click_zone(stencil_node)
		end
	end
end

---内部方法：处理输入事件
---此函数处理所有类型的输入事件，包括鼠标、触摸和键盘输入
---根据输入类型和状态触发相应的按钮事件
---@private
---@param action_id hash 动作ID
---@param action table 动作表
---@return boolean is_consumed 如果输入被消耗则为真
function M:on_input(action_id, action)
	if not self:_is_input_match(action_id) then
		return false
	end

	if not gui.is_enabled(self.node, true) then
		return false
	end

	local is_consume = true
	local is_pick = true
	local is_key_trigger = (action_id == self.key_trigger)
	if not is_key_trigger then
		is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)
	end

	if not is_pick then
		-- Can't interact, if touch outside of button
		self.can_action = false
		if action.released then
			self.on_click_outside:trigger(self:get_context(), self.params, self)
		end

		if self._is_html5_mode and self._is_html5_listener_set then
			self._is_html5_listener_set = false
			html5.set_interaction_listener(nil)
		end
		return false
	end

	if is_key_trigger then
		self.hover:set_hover(not action.released)
		is_consume = false
	end

	if action.pressed then
		-- Can interact if start touch on the button
		self.can_action = true
		self.is_repeated_started = false
		self.last_pressed_time = socket.gettime()
		self.on_pressed:trigger(self:get_context(), self.params, self)

		if self._is_html5_mode then
			self._is_html5_listener_set = true
			html5.set_interaction_listener(function()
				self:button_click()
			end)
		end
		return is_consume
	end

	-- While hold button, repeat rate pick from input.repeat_interval
	if action.repeated then
		if not self.on_repeated_click:is_empty() and self.can_action then
			self:button_repeated_click()
			return is_consume
		end
	end

	if action.released then
		return self:_on_button_release() and is_consume
	end

	if self.can_action and (not self.on_long_click:is_empty() or not self.on_hold_callback:is_empty()) then
		local press_time = socket.gettime() - self.last_pressed_time

		if not self.on_long_click:is_empty() and self.style.AUTOHOLD_TRIGGER <= press_time then
			self:_on_button_release()
			return is_consume
		end

		if press_time >= self.style.LONGTAP_TIME then
			self:button_hold(press_time)
			return is_consume
		end
	end

	return not self.disabled and is_consume
end

---@private
function M:on_input_interrupt(action_id, action)
	self.can_action = false
	self.hover:set_hover(false)
	self.hover:set_mouse_hover(false)

	local is_input_match = self:_is_input_match(action_id) and action.x -- only touch/mouse actions
	local is_enabled = gui.is_enabled(self.node, true)
	-- If pressed outside of button, trigger on_click_outside event
	if is_input_match and is_enabled then
		local is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)
		if not is_pick and action.released then
			self.on_click_outside:trigger(self:get_context(), self.params, self)
		end
	end
end

---Set button enabled state.
---The style.on_set_enabled will be triggered.
---Disabled button is not clickable.
---@param state boolean|nil Enabled state
---@return druid.button self The current button instance
function M:set_enabled(state)
	self.disabled = not state
	self.hover:set_enabled(state)
	self.style.on_set_enabled(self, self.node, state)

	return self
end

---Get button enabled state.
---By default all Buttons are enabled on creating.
---@return boolean is_enabled True, if button is enabled now, False otherwise
function M:is_enabled()
	return not self.disabled
end

---Set additional button click area.
---Useful to restrict click outside of stencil node or scrollable content.
---If button node placed inside stencil node, it will be automatically set to this stencil node.
---@param zone node|string|nil Gui node
---@return druid.button self The current button instance
function M:set_click_zone(zone)
	self.click_zone = zone and self:get_node(zone) or nil
	self.hover:set_click_zone(zone)

	return self
end

---Set key name to trigger this button by keyboard.
---@param key hash|string The action_id of the input key. Example: "key_space"
---@return druid.button self The current button instance
function M:set_key_trigger(key)
	if type(key) == "string" then
		self.key_trigger = hash(key)
	else
		self.key_trigger = key
	end

	return self
end

---Get current key name to trigger this button.
---@return hash key_trigger The action_id of the input key
function M:get_key_trigger()
	return self.key_trigger
end

---Set function for additional check for button click availability.
---@param check_function function|nil Should return true or false. If true - button can be pressed.
---@param failure_callback function|nil Function will be called on button click, if check function returns false
---@return druid.button self The current button instance
function M:set_check_function(check_function, failure_callback)
	self._check_function = check_function
	self._failure_callback = failure_callback

	return self
end

---Set Button mode to work inside user HTML5 interaction event.
---
---It's required to make protected things like copy & paste text, show mobile keyboard, etc
---The HTML5 button doesn't call any events except on_click event.
---
---If the game is not HTML, html mode will be not enabled
---@param is_web_mode boolean|nil If true - button will be called inside html5 callback
---@return druid.button self The current button instance
function M:set_web_user_interaction(is_web_mode)
	self._is_html5_mode = not not (is_web_mode and html5)
	return self
end

---@param action_id hash The action id
---@return boolean is_match True if the input matches the button
function M:_is_input_match(action_id)
	if action_id == const.ACTION_TOUCH or action_id == const.ACTION_MULTITOUCH then
		return true
	end

	if self.key_trigger and action_id == self.key_trigger then
		return true
	end

	return false
end

---Call button style on_hover callback
---@param hover_state boolean True if the hover state is active
function M:button_hover(hover_state)
	self.style.on_hover(self, self.anim_node, hover_state)
end

---Call button style on_hover callback
---@param hover_state boolean True if the hover state is active
function M:button_mouse_hover(hover_state)
	self.style.on_mouse_hover(self, self.anim_node, hover_state)
end

---Call button click callback
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

---Call button repeated click callback
function M:button_repeated_click()
	if not self.is_repeated_started then
		self.click_in_row = 0
		self.is_repeated_started = true
	end

	self.click_in_row = self.click_in_row + 1
	self.on_repeated_click:trigger(self:get_context(), self.params, self, self.click_in_row)
	self.style.on_click(self, self.anim_node)
end

---Call button long click callback
function M:button_long_click()
	self.click_in_row = 1
	local time = socket.gettime() - self.last_pressed_time
	self.on_long_click:trigger(self:get_context(), self.params, self, time)
	self.style.on_click(self, self.anim_node)
end

---Call button double click callback
function M:button_double_click()
	self.click_in_row = self.click_in_row + 1
	self.on_double_click:trigger(self:get_context(), self.params, self, self.click_in_row)
	self.style.on_click(self, self.anim_node)
end

---Call button hold callback
---@param press_time number Amount of time the button was held
function M:button_hold(press_time)
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
