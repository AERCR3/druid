--- 布局示例列表：注册所有布局相关示例
local M = {}

--- 获取所有布局示例的配置列表
---@return druid.example.data[]
function M.get_examples()
	---@type druid.example.data[]
	return {
		--- 基础布局示例
		{
			name_id = "ui_example_layout_basic",
			information_text_id = "ui_example_layout_basic_description",
			template = "basic_layout",
			root = "basic_layout/root",
			code_url = "example/examples/layout/basic/basic_layout.lua",
			widget_class = require("example.examples.layout.basic.basic_layout"),
		}
	}
end

return M
