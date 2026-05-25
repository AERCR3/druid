local event = require("event.event")
local helper = require("druid.helper")
local const = require("druid.const")
local component = require("druid.component")

---基本的Druid滑块组件。在一条线上创建一个可拖动的节点并报告进度。
---
---### 设置
---使用druid创建滑块组件: `slider = druid:new_slider(node_name, end_pos, callback)`
---
---### 注意事项
---- 引脚节点应放置在零进度的初始位置
---- 将可以在起始位置和结束位置之间移动引脚节点
---- 您可以通过`slider:set_steps`在滑块上设置兴趣点。如果存在步骤，滑块值将仅来自这些步骤（带刻度的滑块）
---- 起始位置和结束位置应在垂直或水平线上（它们的x或y值应相等）
---- 要捕获整个滑块的输入，您可以通过`slider:set_input_node`设置输入节点
---滑块组件是用户界面中常用的交互控件，常用于数值调节和进度控制
---@class druid.slider: druid.component
---@field node node 用于管理滑块的节点
---@field on_change_value event fun(self: druid.slider, value: number) 滑块值改变时触发的事件
---@field style table 滑块的样式
---@field private start_pos vector3 滑块的起始位置
---@field private pos vector3 滑块的当前位置
---@field private target_pos vector3 滑块的目标位置
---@field private end_pos vector3 滑块的结束位置
---@field private dist vector3 滑块起始和结束位置之间的距离
---@field private is_drag boolean 滑块是否正在被拖动
---@field private value number 滑块的当前值
---@field private steps number[]? 滑块的步骤
local M = component.create("slider", const.PRIORITY_INPUT_HIGH)


---滑块构造函数
---初始化滑块组件，设置可拖动节点、结束位置和回调函数
---@param node node 作为滑块拖动的GUI节点
---@param end_pos vector3 滑块的结束位置，应与节点在同一轴上
---@param callback function|nil 滑块改变时的回调
function M:init(node, end_pos, callback)
	self.node = self:get_node(node)

	self.start_pos = gui.get_position(self.node)
	self.pos = gui.get_position(self.node)
	self.target_pos = vmath.vector3(self.pos)
	self.end_pos = end_pos
	self._is_enabled = true

	self.dist = self.end_pos - self.start_pos
	self.is_drag = false
	self.value = 0

	self.on_change_value = event.create(callback)
	self:on_window_resized()

	assert(self.dist.x == 0 or self.dist.y == 0, "Slider for now can be only vertical or horizontal")
end

---@private
function M:on_layout_change()
	self:set(self.value)
end

---@private
function M:on_remove()
	-- Return pin to start position
	gui.set_position(self.node, self.start_pos)
end

---@private
---@param style table
function M:on_style_change(style)
	if style.DEFAULT_STEPS and #style.DEFAULT_STEPS > 0 then
		self.steps = style.DEFAULT_STEPS
	end
end

---@private
function M:on_window_resized()
	local x_koef, y_koef = helper.get_screen_aspect_koef()
	self._x_koef = x_koef
	self._y_koef = y_koef
	self._scene_scale = helper.get_scene_scale(self.node)
end

---内部方法：处理输入事件
---此函数处理滑块的拖动输入，计算滑块的新位置和值
---@private
---@param action_id hash 来自on_input的动作ID
---@param action table 来自on_input的动作表
---@return boolean is_consumed 如果输入被消耗则为真
function M:on_input(action_id, action)
	if action_id ~= const.ACTION_TOUCH then
		return false
	end

	if not self._is_enabled or not gui.is_enabled(self.node, true) then
		return false
	end

	if gui.pick_node(self.node, action.x, action.y) then
		if action.pressed then
			self.pos = gui.get_position(self.node)
			self._scene_scale = helper.get_scene_scale(self.node)
			self.is_drag = true
		end
	end

	if not self.is_drag and self._input_node and gui.pick_node(self._input_node, action.x, action.y) then
		if action.pressed and gui.screen_to_local then
			self._scene_scale = helper.get_scene_scale(self.node)
			self.pos = gui.screen_to_local(self.node, vmath.vector3(action.screen_x, action.screen_y, 0))
			self.pos.x = helper.clamp(self.pos.x / self._scene_scale.x, self.start_pos.x, self.end_pos.x)
			self.pos.y = helper.clamp(self.pos.y / self._scene_scale.y, self.start_pos.y, self.end_pos.y)

			gui.set_position(self.node, self.pos)
			self.is_drag = true
		end
	end

	if self.is_drag and not action.pressed then
		-- move
		self.pos.x = self.pos.x + action.dx * self._x_koef / self._scene_scale.x
		self.pos.y = self.pos.y + action.dy * self._y_koef / self._scene_scale.y

		local prev_x = self.target_pos.x
		local prev_y = self.target_pos.y

		self.target_pos.x = helper.clamp(self.pos.x, self.start_pos.x, self.end_pos.x)
		self.target_pos.y = helper.clamp(self.pos.y, self.start_pos.y, self.end_pos.y)

		if prev_x ~= self.target_pos.x or prev_y ~= self.target_pos.y then
			local prev_value = self.value

			if math.abs(self.dist.x) > 0 then
				self.value = (self.target_pos.x - self.start_pos.x) / self.dist.x
			end

			if math.abs(self.dist.y) > 0 then
				self.value = (self.target_pos.y - self.start_pos.y) / self.dist.y
			end

			self.value = math.abs(self.value)

			if self.steps then
				local closest_dist = 1000
				local closest = nil
				for i = 1, #self.steps do
					local dist = math.abs(self.value - self.steps[i])
					if dist < closest_dist then
						closest = self.steps[i]
						closest_dist = dist
					end
				end
				if closest then
					self.value = closest
				end
			end

			if prev_value ~= self.value then
				self:_on_change_value()
			end
		end

		self:_set_position(self.value)
	end

	if action.released then
		self.is_drag = false
	end

	return self.is_drag
end

---Set value for slider
---@param value number Value from 0 to 1
---@param is_silent boolean|nil Don't trigger event if true
---@return druid.slider self Current slider instance
function M:set(value, is_silent)
	value = helper.clamp(value, 0, 1)
	self:_set_position(value)
	self.value = value
	if not is_silent then
		self:_on_change_value()
	end

	return self
end

---Set slider steps. Pin node will
---apply closest step position
---@param steps number[] Array of steps
---@return druid.slider self Current slider instance
function M:set_steps(steps)
	self.steps = steps
	return self
end

---Adjust the end position of the slider
---@param end_pos vector3 The end position of the slider
---@return druid.slider self Current slider instance
function M:set_end_pos(end_pos)
	self.end_pos = end_pos
	self.dist = self.end_pos - self.start_pos
	self:set(self.value)
	return self
end

---Set input zone for slider.
---User can touch any place of node, pin instantly will
---move at this position and node drag will start.
---This function require the Defold version 1.3.0+
---@param input_node node|string|nil
---@return druid.slider self Current slider instance
function M:set_input_node(input_node)
	if not input_node then
		self._input_node = nil
		return self
	end

	self._input_node = self:get_node(input_node)
	return self
end

---Set Slider input enabled or disabled
---@param is_enabled boolean True if slider is enabled
---@return druid.slider self Current slider instance
function M:set_enabled(is_enabled)
	self._is_enabled = is_enabled

	return self
end

---Check if Slider component is enabled
---@return boolean is_enabled True if slider is enabled
function M:is_enabled()
	return self._is_enabled
end

---@private
function M:_on_change_value()
	self.on_change_value:trigger(self:get_context(), self.value)
end

---@private
function M:_set_position(value)
	value = helper.clamp(value, 0, 1)
	gui.set_position(self.node, self.start_pos + self.dist * value)
end

return M
