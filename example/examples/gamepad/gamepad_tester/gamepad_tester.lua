--- 游戏手柄测试器示例：展示所有游戏手柄按钮、摇杆和扳机的映射和测试
---@class examples.gamepad_tester: druid.widget
---@field root node
---@field button_left druid.button
---@field button_right druid.button
---@field button_up druid.button
---@field button_down druid.button
---@field button_x druid.button
---@field button_b druid.button
---@field button_y druid.button
---@field button_a druid.button
---@field button_l1 druid.button
---@field button_r1 druid.button
---@field button_stick_left druid.button
---@field button_stick_right druid.button
---@field button_start druid.button
---@field button_back druid.button
---@field trigger_l2 druid.progress
---@field trigger_r2 druid.progress
---@field stick_left node
---@field stick_right node
local M = {}

-- 摇杆最大移动距离（像素）
local STICK_DISTANCE = 50


function M:init()
	self.root = self:get_node("root")

	self.button_left = self.druid:new_button("button_left/button"):set_key_trigger("gamepad_lpad_left")
	self.button_right = self.druid:new_button("button_right/button"):set_key_trigger("gamepad_lpad_right")
	self.button_up = self.druid:new_button("button_up/button"):set_key_trigger("gamepad_lpad_up")
	self.button_down = self.druid:new_button("button_down/button"):set_key_trigger("gamepad_lpad_down")

	self.button_x = self.druid:new_button("button_x/button"):set_key_trigger("gamepad_rpad_left")
	self.button_b = self.druid:new_button("button_b/button"):set_key_trigger("gamepad_rpad_right")
	self.button_y = self.druid:new_button("button_y/button"):set_key_trigger("gamepad_rpad_up")
	self.button_a = self.druid:new_button("button_a/button"):set_key_trigger("gamepad_rpad_down")

	self.button_l1 = self.druid:new_button("button_l1/button"):set_key_trigger("gamepad_lshoulder")
	self.button_r1 = self.druid:new_button("button_r1/button"):set_key_trigger("gamepad_rshoulder")

	self.button_stick_left = self.druid:new_button("stick_left/root"):set_key_trigger("gamepad_lstick_click")
	self.button_stick_right = self.druid:new_button("stick_right/root"):set_key_trigger("gamepad_rstick_click")

	self.button_start = self.druid:new_button("button_start/button"):set_key_trigger("gamepad_start")
	self.button_back = self.druid:new_button("button_back/button"):set_key_trigger("gamepad_back")

	self.trigger_l2 = self.druid:new_progress("button_l2/fill", "x", 0) --[[@as druid.progress]]
	self.trigger_r2 = self.druid:new_progress("button_r2/fill", "x", 0) --[[@as druid.progress]]

	self.stick_left = self:get_node("stick_left/stick_root")
	self.stick_right = self:get_node("stick_right/stick_root")
end

function M:on_input(action_id, action)
	if action_id == hash("gamepad_ltrigger") then
		self.trigger_l2:set_to(action.value)
	end
	if action_id == hash("gamepad_rtrigger") then
		self.trigger_r2:set_to(action.value)
	end

	-- 左摇杆
	if action_id == hash("gamepad_lstick_left") then
		gui.set(self.stick_left, "position.x", -action.value * STICK_DISTANCE)
	end
	if action_id == hash("gamepad_lstick_right") then
		gui.set(self.stick_left, "position.x", action.value * STICK_DISTANCE)
	end
	if action_id == hash("gamepad_lstick_up") then
		gui.set(self.stick_left, "position.y", action.value * STICK_DISTANCE)
	end
	if action_id == hash("gamepad_lstick_down") then
		gui.set(self.stick_left, "position.y", -action.value * STICK_DISTANCE)
	end

	-- 右摇杆
	if action_id == hash("gamepad_rstick_left") then
		gui.set(self.stick_right, "position.x", -action.value * STICK_DISTANCE)
	end
	if action_id == hash("gamepad_rstick_right") then
		gui.set(self.stick_right, "position.x", action.value * STICK_DISTANCE)
	end
	if action_id == hash("gamepad_rstick_up") then
		gui.set(self.stick_right, "position.y", action.value * STICK_DISTANCE)
	end
	if action_id == hash("gamepad_rstick_down") then
		gui.set(self.stick_right, "position.y", -action.value * STICK_DISTANCE)
	end
end

---@param output_list output_list
function M:on_example_created(output_list)
	-- 订阅所有游戏手柄按钮的点击事件并记录日志
	self.button_left.on_click:subscribe(function()
		output_list:add_log_text("左方向按钮已点击")
	end)
	self.button_right.on_click:subscribe(function()
		output_list:add_log_text("右方向按钮已点击")
	end)
	self.button_up.on_click:subscribe(function()
		output_list:add_log_text("上方向按钮已点击")
	end)
	self.button_down.on_click:subscribe(function()
		output_list:add_log_text("下方向按钮已点击")
	end)
	self.button_a.on_click:subscribe(function()
		output_list:add_log_text("A按钮已点击")
	end)
	self.button_b.on_click:subscribe(function()
		output_list:add_log_text("B按钮已点击")
	end)
	self.button_x.on_click:subscribe(function()
		output_list:add_log_text("X按钮已点击")
	end)
	self.button_y.on_click:subscribe(function()
		output_list:add_log_text("Y按钮已点击")
	end)
	self.button_back.on_click:subscribe(function()
		output_list:add_log_text("Back按钮已点击")
	end)
	self.button_start.on_click:subscribe(function()
		output_list:add_log_text("Start按钮已点击")
	end)
	self.button_l1.on_click:subscribe(function()
		output_list:add_log_text("L1按钮已点击")
	end)
	self.button_r1.on_click:subscribe(function()
		output_list:add_log_text("R1按钮已点击")
	end)
	self.button_stick_left.on_click:subscribe(function()
		output_list:add_log_text("左摇杆按钮已点击")
	end)
	self.button_stick_right.on_click:subscribe(function()
		output_list:add_log_text("右摇杆按钮已点击")
	end)
end

return M
