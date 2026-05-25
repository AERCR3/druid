--- 容器示例列表：注册所有容器相关示例
local M = {}

--- 获取所有容器示例的配置列表
---@return druid.example.data[]
function M.get_examples()
	---@type druid.example.data[]
	return {
		--- 容器锚点示例
		{
			name_id = "ui_example_container_anchors",
			information_text_id = "ui_example_container_anchors_description",
			template = "container_anchors",
			root = "container_anchors/root",
			code_url = "example/examples/container/container_anchors/container_anchors.lua",
			widget_class = require("example.examples.container.container_anchors.container_anchors"),
		},
		--- 容器自适应大小示例
		{
			information_text_id = "ui_example_container_resize_description",
			template = "container_resize",
			root = "container_resize/root",
			code_url = "example/examples/container/container_resize/container_resize.lua",
			widget_class = require("example.examples.container.container_resize.container_resize"),
		}
	}
end

return M
