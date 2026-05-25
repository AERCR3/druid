--- 数据列表示例列表：注册所有数据列表相关示例
local M = {}

--- 获取所有数据列表示例的配置列表
---@return druid.example.data[]
function M.get_examples()
	---@type druid.example.data[]
	return {
		--- 基础数据列表示例
		{
			name_id = "ui_example_data_list_basic",
			information_text_id = "ui_example_data_list_basic_description",
			template = "data_list_basic",
			root = "data_list_basic/root",
			code_url = "example/examples/data_list/basic/data_list_basic.lua",
			widget_class = require("example.examples.data_list.basic.data_list_basic"),
		},
		--- 水平数据列表示例

		{
			name_id = "ui_example_data_list_horizontal_basic",
			information_text_id = "ui_example_data_list_horizontal_basic_description",
			template = "data_list_horizontal_basic",
			root = "data_list_horizontal_basic/root",
			code_url = "example/examples/data_list/basic/data_list_horizontal_basic.lua",
			widget_class = require("example.examples.data_list.basic.data_list_horizontal_basic"),
		},

		--- 矩阵数据列表示例
		{
			name_id = "ui_example_data_list_matrix_basic",
			information_text_id = "ui_example_data_list_matrix_basic_description",
			template = "data_list_matrix_basic",
			root = "data_list_matrix_basic/root",
			code_url = "example/examples/data_list/basic/data_list_matrix_basic.lua",
			widget_class = require("example.examples.data_list.basic.data_list_matrix_basic"),
		},

		--- 数据列表增删清空示例
		{
			name_id = "ui_example_data_list_add_remove_clear",
			information_text_id = "ui_example_data_list_add_remove_clear_description",
			template = "data_list_add_remove_clear",
			root = "data_list_add_remove_clear/root",
			code_url = "example/examples/data_list/add_remove_clear/data_list_add_remove_clear.lua",
			widget_class = require("example.examples.data_list.add_remove_clear.data_list_add_remove_clear"),
		},

		--- 带组件缓存的数据列表示例
		{
			name_id = "ui_example_data_list_cache_with_component",
			information_text_id = "ui_example_data_list_cache_with_component_description",
			template = "data_list_cache_with_component",
			root = "data_list_cache_with_component/root",
			code_url = "example/examples/data_list/cache_with_component/cache_with_component.lua",
			widget_class = require("example.examples.data_list.cache_with_component.cache_with_component"),
		},
	}
end

return M
