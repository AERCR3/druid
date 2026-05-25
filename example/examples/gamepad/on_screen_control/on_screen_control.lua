local on_screen_input = require("example.examples.gamepad.on_screen_control.on_screen_input")

--- 屏幕控制示例：展示虚拟摇杆和按钮的屏幕输入控制，用于移动角色
---@class examples.on_screen_control: druid.widget
---@field on_screen_input examples.on_screen_input
---@field character node
---@field character_position vector3
---@field character_eye_left node
---@field character_eye_right node
local M = {}

-- 角色移动速度（像素/秒）
local CHARACTER_SPEED = 700


--- 初始化函数：创建角色节点和屏幕输入组件，并订阅事件
function M:init()
	self.character = self:get_node("character")
	self.character_position = gui.get_position(self.character)

	self.character_eye_left = self:get_node("eye_left")
	self.character_eye_right = self:get_node("eye_right")

	-- 创建屏幕输入组件（虚拟摇杆和按钮）
	self.on_screen_input = self.druid:new_widget(on_screen_input, "on_screen_input")

	-- 订阅动作按钮、移动和移动停止事件
	self.on_screen_input.on_action:subscribe(self.on_action_button, self)
	self.on_screen_input.on_movement:subscribe(self.on_movement, self)
	self.on_screen_input.on_movement_stop:subscribe(self.on_movement_stop, self)
end

--- 动作按钮回调：点击时让角色放大然后恢复原状
function M:on_action_button()
	gui.set_scale(self.character, vmath.vector3(1.5))
	gui.animate(self.character, gui.PROP_SCALE, vmath.vector3(1), gui.EASING_INSINE, 0.2)
end

--- 移动处理：根据摇杆输入更新角色位置和眼睛方向
---@param x number 水平移动方向（-1到1）
---@param y number 垂直移动方向（-1到1）
---@param dt number 时间增量
function M:on_movement(x, y, dt)
	-- 根据速度和方向更新角色位置
	self.character_position.x = self.character_position.x + x * CHARACTER_SPEED * dt
	self.character_position.y = self.character_position.y + y * CHARACTER_SPEED * dt

	-- 将位置限制在屏幕区域内（-436..436）
	self.character_position.x = math.min(436, math.max(-436, self.character_position.x))
	self.character_position.y = math.min(436, math.max(-436, self.character_position.y))

	gui.set_position(self.character, self.character_position)

	-- 根据移动方向调整眼睛转向，使眼睛看向移动方向
	local angle = math.deg(math.atan2(y, x)) - 135
	gui.set(self.character_eye_left, "euler.z", angle)
	gui.set(self.character_eye_right, "euler.z", angle)
end

--- 移动停止回调：当摇杆释放时，将眼睛重置为默认方向
function M:on_movement_stop()
	gui.set(self.character_eye_left, "euler.z", 0)
	gui.set(self.character_eye_right, "euler.z", 0)
end

return M
