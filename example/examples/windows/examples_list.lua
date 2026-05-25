--- 窗口示例列表：注册所有窗口相关示例
local M = {}

--- 获取所有窗口示例的配置列表
---@return druid.example.data[]
function M.get_examples()
	---@type druid.example.data[]
	return {
		--- 语言切换窗口示例
		{
			name_id = "ui_example_window_language",
			information_text_id = "ui_example_window_language_description",
			template = "window_language",
			root = "window_language/root",
			code_url = "example/examples/windows/window_language/window_language.lua",
			widget_class = require("example.examples.windows.window_language.window_language"),
		},
		--- 确认窗口示例
		{
			name_id = "ui_example_window_confirmation",
			template = "window_confirmation",
			root = "window_confirmation/root",
			information_text_id = "ui_example_window_language_description",
			code_url = "example/examples/windows/window_confirmation/window_confirmation.lua",
			widget_class = require("example.examples.windows.window_confirmation.window_confirmation"),
		},
		--- 信息窗口示例
		{
			name_id = "ui_example_window_information",
			template = "window_info",
			root = "window_info/root",
			information_text_id = "ui_example_window_information_description",
			code_url = "example/examples/windows/window_info/window_info.lua",
			widget_class = require("example.examples.windows.window_info.window_info"),
		}
	}
end

return M
