--- 密码输入框示例：展示密码输入框的使用
---@class examples.input_password: druid.widget
---@field root node
---@field input druid.input
local M = {}


--- 初始化函数：创建密码输入框，订阅取消选中事件
function M:init()
	self.root = self:get_node("root")
	self.input = self.druid:new_input("input/root", "input/text", gui.KEYBOARD_TYPE_PASSWORD)
	self.input:set_text("")

	self.input.on_input_unselect:subscribe(function(_, text)
		print(text)
	end)
end

--- 示例创建回调：订阅输入框取消选中事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	self.input.on_input_unselect:subscribe(function(_, text)
		output_log:add_log_text("输入框: " .. text)
	end)
end

return M
