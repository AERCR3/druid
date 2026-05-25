--- 手柄示例列表：注册所有手柄相关示例
local M = {}

--- 获取所有手柄示例的配置列表
---@return druid.example.data[]
function M.get_examples()
	---@type druid.example.data[]
	return {
		--- 手柄测试器示例
		{
			name_id = "ui_example_gamepad_tester",
			information_text_id = "ui_example_gamepad_tester_description",
			template = "gamepad_tester",
			root = "gamepad_tester/root",
			code_url = "example/examples/gamepad/gamepad_tester/gamepad_tester.lua",
			widget_class = require("example.examples.gamepad.gamepad_tester.gamepad_tester"),
		},
		--- 虚拟摇杆示例
		{
			name_id = "ui_example_on_screen_control",
			information_text_id = "ui_example_on_screen_control_description",
			template = "on_screen_control",
			root = "on_screen_control/root",
			code_url = "example/examples/gamepad/on_screen_control/on_screen_control.lua",
			widget_class = require("example.examples.gamepad.on_screen_control.on_screen_control"),
		}
	}
end

return M
