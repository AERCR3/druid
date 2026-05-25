local event = require("event.event")
local const = require("druid.const")
local helper = require("druid.helper")
local component = require("druid.component")

---@class druid.drag.style
---@field DRAG_DEADZONE number 开始拖动的距离（像素）。默认值: 10
---@field NO_USE_SCREEN_KOEF boolean 屏幕宽高比是否影响拖动值。默认值: false

---允许您订阅节点上的拖动事件的组件
---拖动组件用于处理UI元素的拖放操作，支持水平和垂直拖动
---@class druid.drag: druid.component
---@field node node 订阅拖动事件的节点
---@field on_touch_start event fun(self, touch) 触摸开始时触发的事件
---@field on_touch_end event fun(self, touch) 触摸结束时触发的事件
---@field on_drag_start event fun(self, touch) 拖动开始时触发的事件
---@field on_drag event fun(self, touch) 拖动发生时触发的事件
---@field on_drag_end event fun(self, touch) 拖动结束时触发的事件
---@field style druid.drag.style 拖动组件的样式
---@field click_zone node|nil 拖动组件的点击区域
---@field is_touch boolean 如果触摸处于活动状态则为真
---@field is_drag boolean 如果拖动处于活动状态则为真
---@field can_x boolean 如果拖动可以在水平方向移动则为真
---@field can_y boolean 如果拖动可以在垂直方向移动则为真
---@field dx number 水平拖动距离
---@field dy number 垂直拖动距离
---@field touch_id number 触摸ID
---@field x number 当前x位置
---@field y number 当前y位置
---@field screen_x number 当前屏幕x位置
---@field screen_y number 当前屏幕y位置
---@field touch_start_pos vector3 触摸开始位置
---@field private _is_enabled boolean 如果拖动组件已启用则为真
---@field private _x_koef number x系数
---@field private _y_koef number y系数
local M = component.create("drag", const.PRIORITY_INPUT_HIGH)


---拖动组件的构造函数
---初始化拖动组件，设置订阅拖动事件的节点和拖动回调函数
---@param node_or_node_id node|string 订阅拖动事件的节点或节点ID
---@param on_drag_callback fun(self, touch) 拖动发生时调用的回调函数
function M:init(node_or_node_id, on_drag_callback)
	self.druid = self:get_druid()
	self.node = self:get_node(node_or_node_id)
	self.hover = self.druid:new_hover(self.node)

	self.dx = 0
	self.dy = 0
	self.touch_id = 0
	self.x = 0
	self.y = 0
	self.screen_x = 0
	self.screen_y = 0
	self.is_touch = false
	self.is_drag = false
	self.touch_start_pos = vmath.vector3(0)
	self._is_enabled = true

	self.can_x = true
	self.can_y = true

	self._scene_scale = helper.get_scene_scale(self.node)

	self.click_zone = nil
	self.on_touch_start = event.create()
	self.on_touch_end = event.create()
	self.on_drag_start = event.create()
	self.on_drag = event.create(on_drag_callback)
	self.on_drag_end = event.create()

	self:on_window_resized()
	self:set_drag_cursors(true)
end

---内部方法：处理样式变化
---当拖动组件样式发生变化时调用此私有方法
---@private
---@param style druid.drag.style 拖动组件的样式
function M:on_style_change(style)
	self.style = {
		DRAG_DEADZONE = style.DRAG_DEADZONE or 10,
		NO_USE_SCREEN_KOEF = style.NO_USE_SCREEN_KOEF or false,
	}
end

---设置拖动组件光标状态。
---此函数根据是否启用拖动来设置鼠标光标样式
---@param is_enabled boolean 如果拖动组件启用则为真
function M:set_drag_cursors(is_enabled)
	if defos and is_enabled then
		self.hover.style.ON_HOVER_CURSOR = defos.CURSOR_CROSSHAIR
		self.hover.style.ON_MOUSE_HOVER_CURSOR = defos.CURSOR_HAND
	else
		self.hover.style.ON_HOVER_CURSOR = nil
		self.hover.style.ON_MOUSE_HOVER_CURSOR = nil
	end
end

---@private
function M:on_late_init()
	if not self.click_zone then
		local stencil_node = helper.get_closest_stencil_node(self.node)
		if stencil_node then
			self:set_click_zone(stencil_node)
		end
	end
end

---@private
function M:on_window_resized()
	local x_koef, y_koef = helper.get_screen_aspect_koef()
	self._x_koef = x_koef
	self._y_koef = y_koef
	self._scene_scale = helper.get_scene_scale(self.node)
end

---@private
function M:on_input_interrupt()
	if self.is_drag or self.is_touch then
		self:_end_touch()
	end
end

---@private
---@param action_id hash 来自on_input的动作ID
---@param action table 来自on_input的动作表
---@return boolean is_consumed 如果输入被消耗则为真
function M:on_input(action_id, action)
	if action_id ~= const.ACTION_TOUCH and action_id ~= const.ACTION_MULTITOUCH then
		return false
	end

	if not self._is_enabled or not gui.is_enabled(self.node, true) then
		return false
	end

	local is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)
	if not is_pick and not self.is_drag then
		self:_end_touch()
		return false
	end


	local touch = self:_find_touch(action_id, action, self.touch_id)
	if not touch then
		return false
	end

	if touch.id then
		self.touch_id = touch.id
	end

	self.dx = 0
	self.dy = 0

	if touch.pressed and not self.is_touch then
		self:_start_touch(touch)
	end

	if touch.released and self.is_touch then
		if action.touch then
			-- 移动设备
			self:_on_touch_release(action_id, action, touch)
		else
			-- PC端
			self:_end_touch(touch)
		end
	end

	if self.is_touch then
		self:_process_touch(touch)
	end

	local touch_modified = self:_find_touch(action_id, action, self.touch_id)
	if touch_modified and self.is_drag then
		self.dx = touch_modified.x - self.x
		self.dy = touch_modified.y - self.y
	end

	if touch_modified then
		self.x = touch_modified.x
		self.y = touch_modified.y

		self.screen_x = touch_modified.screen_x
		self.screen_y = touch_modified.screen_y
	end

	if self.is_drag and (self.dx ~= 0 or self.dy ~= 0) then
		local x_koef, y_koef = self._x_koef, self._y_koef
		if self.style.NO_USE_SCREEN_KOEF then
			x_koef, y_koef = 1, 1
		end

		self.on_drag:trigger(self:get_context(),
			self.dx * x_koef / self._scene_scale.x,
			self.dy * y_koef / self._scene_scale.y,
			(self.x - self.touch_start_pos.x) * x_koef / self._scene_scale.x,
			(self.y - self.touch_start_pos.y) * y_koef / self._scene_scale.y, touch_modified)
	end

	return self.is_drag
end

---设置拖动点击区域
---@param node node|string|nil 节点或节点ID
---@return druid.drag self 当前实例
function M:set_click_zone(node)
	self.click_zone = node and self:get_node(node) or nil

	return self
end

---设置拖动组件启用状态
---@param is_enabled boolean
---@return druid.drag self 当前实例
function M:set_enabled(is_enabled)
	self._is_enabled = is_enabled

	return self
end

---检查拖动组件是否捕获输入
---@return boolean is_enabled 如果拖动组件已启用则返回true
function M:is_enabled()
	return self._is_enabled
end

function M:_start_touch(touch)
	self.is_touch = true
	self.is_drag = false

	self.touch_start_pos.x = touch.x
	self.touch_start_pos.y = touch.y

	self.x = touch.x
	self.y = touch.y

	self.screen_x = touch.screen_x
	self.screen_y = touch.screen_y

	self._scene_scale = helper.get_scene_scale(self.node)

	self.on_touch_start:trigger(self:get_context(), touch)
end

---@param touch touch|nil 触摸动作对象
function M:_end_touch(touch)
	if self.is_drag then
		self.on_drag_end:trigger(
			self:get_context(),
			self.x - self.touch_start_pos.x,
			self.y - self.touch_start_pos.y,
			touch
		)
	end

	self.is_drag = false
	if self.is_touch then
		self.is_touch = false
		self.on_touch_end:trigger(self:get_context(), touch)
	end
	self:reset_input_priority()
	self.touch_id = 0
end

---@param touch touch 触摸动作对象
function M:_process_touch(touch)
	if not self.can_x then
		self.touch_start_pos.x = touch.x
	end

	if not self.can_y then
		self.touch_start_pos.y = touch.y
	end

	local distance = helper.distance(touch.x, touch.y, self.touch_start_pos.x, self.touch_start_pos.y)
	if not self.is_drag and distance >= self.style.DRAG_DEADZONE then
		self.is_drag = true
		self.on_drag_start:trigger(self:get_context(), touch)
		self:set_input_priority(const.PRIORITY_INPUT_MAX, true)
	end
end

---从动作输入数据返回当前触摸动作
---如果存储了touch_id - 返回确切的触摸动作
---@param action_id hash 来自on_input的动作ID
---@param action table 来自on_input的动作
---@param touch_id number 触摸ID
---@return table|nil touch 触摸动作对象
function M:_find_touch(action_id, action, touch_id)
	local act = helper.is_mobile() and const.ACTION_MULTITOUCH or const.ACTION_TOUCH

	if action_id ~= act then
		return
	end

	if action.touch then
		local touch = action.touch
		for i = 1, #touch do
			if touch[i].id == touch_id then
				return touch[i]
			end
		end
		return touch[1]
	else
		return action
	end
end

---处理触摸释放事件。我们需要查找是否存在其他
---触摸动作以切换到另一个触摸
---@param action_id hash 来自on_input的动作ID
---@param action table 来自on_input的动作
---@param touch table 触摸动作
function M:_on_touch_release(action_id, action, touch)
	if #action.touch >= 2 then
		-- Find next unpressed touch
		local next_touch
		for i = 1, #action.touch do
			if not action.touch[i].released then
				next_touch = action.touch[i]
				break
			end
		end

		if next_touch then
			self.x = next_touch.x
			self.y = next_touch.y
			self.touch_id = next_touch.id
		else
			self:_end_touch(touch)
		end
	elseif #action.touch == 1 then
		self:_end_touch(touch)
	end
end

return M
