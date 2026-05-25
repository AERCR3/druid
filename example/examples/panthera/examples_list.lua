--- Panthera 动画示例列表：注册所有 Panthera 动画相关示例
local panthera = require("panthera.panthera")

local M = {}

--- 获取所有 Panthera 动画示例的配置列表
function M.get_examples()
	return {
		--- 基础动画示例
		{
			name_id = "ui_example_panthera_basic_animation",
			information_text_id = "ui_example_panthera_basic_animation_description",
			template = "basic_animation",
			root = "basic_animation/root",
			code_url = "example/examples/panthera/basic_animation/basic_animation.lua",
			widget_class = require("example.examples.panthera.basic_animation.basic_animation"),
		},
		--- 动画混合示例
		{
			name_id = "ui_example_panthera_animation_blend",
			information_text_id = "ui_example_panthera_animation_blend_description",
			template = "animation_blend",
			root = "animation_blend/root",
			code_url = "example/examples/panthera/animation_blend/animation_blend.lua",
			widget_class = require("example.examples.panthera.animation_blend.animation_blend"),
		}
	}
end

return M
