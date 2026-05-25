local const = require("druid.const")
local event = require("event.event")
local helper = require("druid.helper")

--- 屏幕输入组件：处理虚拟摇杆和按钮的触摸输入，支持多点触控
---@class examples.on_screen_input: druid.widget
---@field button_action node
---@field on_screen_control node
---@field stick_root node
---@field stick_position vector3
---@field on_action event @()
---@field on_movement event @(x: number, y: number, dt: number) x/y 的取值范围为 -1..1
---@field on_movement_stop event @()
---@field is_multitouch boolean
---@field _is_stick_drag boolean|number
---@field _prev_x number
---@field _prev_y number
local M = {}

-- 摇杆最大移动距离（像素）
local STICK_DISTANCE = 80


--- 初始化函数：创建节点引用、事件对象，并检测是否支持多点触控
function M:init()
	self.button_action = self:get_node("on_screen_button")
	self.on_screen_control = self:get_node("on_screen_stick/root")

	self.stick_root = self:get_node("on_screen_stick/stick_root")
	self.stick_position = gui.get_position(self.stick_root)

	-- 创建事件对象
	self.on_action = event.create()
	self.on_movement = event.create()
	self.on_movement_stop = event.create()

	-- 检测设备是否支持多点触控
	self.is_multitouch = helper.is_multitouch_supported()
end

--- 输入处理：根据是否支持多点触控，处理不同的触摸事件
---@param action_id hash 动作ID
---@param action action 动作数据
function M:on_input(action_id, action)
	if self.is_multitouch then
		-- 多点触控模式：处理所有触摸点
		if action_id == const.ACTION_MULTITOUCH then
			for _, touch in ipairs(action.touch) do
				self:process_touch(touch)
			end
		end
	else
		-- 单点触控模式：只处理单个触摸点
		if action_id == const.ACTION_TOUCH then
			self:process_touch(action)
		end
	end

	return false
end

--- 处理单个触摸事件：检测按钮点击和摇杆拖动
---@param action action|touch 触摸动作数据
function M:process_touch(action)
	-- 检测按钮点击：如果触摸点在按钮区域内且按下，触发动作事件
	if action.pressed and gui.pick_node(self.button_action, action.x, action.y) then
		self.on_action:trigger()

		-- 按钮点击动画：先放大再恢复
		gui.animate(self.button_action, gui.PROP_SCALE, vmath.vector3(1.2), gui.EASING_OUTSINE, 0.1, 0, function()
			gui.animate(self.button_action, gui.PROP_SCALE, vmath.vector3(1), gui.EASING_INSINE, 0.2, 0.05)
		end)
	end

	-- 检测摇杆区域：如果触摸点在摇杆控制区域内，开始拖动
	if gui.pick_node(self.on_screen_control, action.x, action.y) then
		self._is_stick_drag = action.id or true
	end

	-- 检查是否是同一个触摸ID，确保只有起始触摸点能控制摇杆
	local is_the_same_touch_id = not action.id or action.id == self._is_stick_drag
	if self._is_stick_drag and is_the_same_touch_id then
		-- 某些情况下 touch 里的 action.dx / action.dy 不可靠，这里手动计算位移更稳定
		local dx = action.x - (self._prev_x or action.x)
		local dy = action.y - (self._prev_y or action.y)
		self._prev_x = action.x
		self._prev_y = action.y

		-- 更新摇杆位置
		self.stick_position.x = self.stick_position.x + dx
		self.stick_position.y = self.stick_position.y + dy

		-- 将摇杆位移限制在 STICK_DISTANCE 半径内
		local length = vmath.length(self.stick_position)
		if length > STICK_DISTANCE then
			self.stick_position.x = self.stick_position.x / length * STICK_DISTANCE
			self.stick_position.y = self.stick_position.y / length * STICK_DISTANCE
		end

		gui.set_position(self.stick_root, self.stick_position)
	end

	-- 触摸释放：重置摇杆位置并触发停止事件
	if action.released and is_the_same_touch_id then
		self._is_stick_drag = false
		self.stick_position.x = 0
		self.stick_position.y = 0
		self._prev_x = nil
		self._prev_y = nil
		gui.animate(self.stick_root, gui.PROP_POSITION, self.stick_position, gui.EASING_OUTBACK, 0.3)
		self.on_movement_stop:trigger()
	end
end

--- 每帧更新：如果摇杆有位移，触发移动事件并归一化输出值
---@param dt number 时间增量
function M:update(dt)
	if self.stick_position.x ~= 0 or self.stick_position.y ~= 0 then
		-- 将摇杆位置归一化为 -1 到 1 的范围，并触发移动事件
		self.on_movement:trigger(self.stick_position.x / STICK_DISTANCE, self.stick_position.y / STICK_DISTANCE, dt)
	end
end

return M
