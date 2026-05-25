--- 基础组件示例列表：注册所有基础组件示例（按钮、文本、拖拽、滑块等）
local M = {}

--- 获取所有基础组件示例的配置列表
---@return druid.example.data[]
function M.get_examples()
	---@type druid.example.data[]
	return {
		--- 普通按钮示例
		{
			information_text_id = "ui_example_basic_button_description",
			template = "basic_button",
			root = "basic_button/root",
			code_url = "example/examples/basic/button/basic_button.lua",
			widget_class = require("example.examples.basic.button.basic_button"),
		},
		--- 双击按钮示例
		{
			name_id = "ui_example_basic_button_double_click",
			information_text_id = "ui_example_basic_button_double_click_description",
			template = "basic_button_double_click",
			root = "basic_button_double_click/root",
			code_url = "example/examples/basic/button/basic_button_double_click.lua",
			widget_class = require("example.examples.basic.button.basic_button_double_click"),
		},
		--- 长按按钮示例
		{
			name_id = "ui_example_basic_button_hold",
			information_text_id = "ui_example_basic_button_hold_description",
			template = "basic_button_hold",
			root = "basic_button_hold/root",
			code_url = "example/examples/basic/button/basic_button_hold.lua",
			widget_class = require("example.examples.basic.button.basic_button_hold"),
		},
		--- 基础文本示例
		{
			name_id = "ui_example_basic_text",
			information_text_id = "ui_example_basic_text_description",
			template = "basic_text",
			root = "basic_text/root",
			code_url = "example/examples/basic/text/basic_text.lua",
			widget_class = require("example.examples.basic.text.basic_text"),
		},
		--- 多行文本示例
		{
			name_id = "ui_example_basic_multiline_text",
			information_text_id = "ui_example_basic_multiline_text_description",
			template = "multiline_text",
			root = "multiline_text/root",
			code_url = "example/examples/basic/text/multiline_text.lua",
			widget_class = require("example.examples.basic.text.multiline_text"),
		},
		--- 悬停示例
		{
			name_id = "ui_example_basic_hover",
			information_text_id = "ui_example_basic_hover_description",
			template = "hover",
			root = "hover/root",
			code_url = "example/examples/basic/hover/hover.lua",
			widget_class = require("example.examples.basic.hover.hover"),
		},
		--- 拖拽示例
		{
			name_id = "ui_example_basic_drag",
			information_text_id = "ui_example_basic_drag_description",
			template = "drag",
			root = "drag/root",
			code_url = "example/examples/basic/drag/drag.lua",
			widget_class = require("example.examples.basic.drag.drag"),
		},
		--- 拖拽到节点示例
		{
			name_id = "ui_example_basic_drag_to_node",
			information_text_id = "ui_example_basic_drag_to_node_description",
			template = "drag_to_node",
			root = "drag_to_node/root",
			code_url = "example/examples/basic/drag/drag_to_node.lua",
			widget_class = require("example.examples.basic.drag.drag_to_node"),
		},
		--- 水平滑块示例
		{
			name_id = "ui_example_basic_slider",
			information_text_id = "ui_example_basic_slider_description",
			template = "basic_slider",
			root = "basic_slider/root",
			code_url = "example/examples/basic/slider/basic_slider.lua",
			widget_class = require("example.examples.basic.slider.basic_slider"),
		},
		--- 垂直滑块示例
		{
			name_id = "ui_example_basic_slider_vertical",
			information_text_id = "ui_example_basic_slider_vertical_description",
			template = "basic_slider_vertical",
			root = "basic_slider_vertical/root",
			code_url = "example/examples/basic/slider/basic_slider_vertical.lua",
			widget_class = require("example.examples.basic.slider.basic_slider_vertical"),
		},
		--- 步进滑块示例
		{
			name_id = "ui_example_basic_slider_stepped",
			information_text_id = "ui_example_basic_slider_stepped_description",
			template = "basic_slider_stepped",
			root = "basic_slider_stepped/root",
			code_url = "example/examples/basic/slider/basic_slider_stepped.lua",
			widget_class = require("example.examples.basic.slider.basic_slider_stepped"),
		},
		--- 进度条示例
		{
			name_id = "ui_example_basic_progress_bar",
			information_text_id = "ui_example_basic_progress_bar_description",
			template = "basic_progress_bar",
			root = "basic_progress_bar/root",
			code_url = "example/examples/basic/progress_bar/basic_progress_bar.lua",
			widget_class = require("example.examples.basic.progress_bar.basic_progress_bar"),
		},
		--- 九宫格进度条示例
		{
			name_id = "ui_example_basic_progress_bar_slice9",
			information_text_id = "ui_example_basic_progress_bar_slice9_description",
			template = "basic_progress_bar_slice9",
			root = "basic_progress_bar_slice9/root",
			code_url = "example/examples/basic/progress_bar/basic_progress_bar_slice9.lua",
			widget_class = require("example.examples.basic.progress_bar.basic_progress_bar_slice9"),
		},
		--- 输入拦截器示例
		{
			name_id = "ui_example_basic_blocker",
			information_text_id = "ui_example_basic_blocker_description",
			template = "basic_blocker",
			root = "basic_blocker/root",
			code_url = "example/examples/basic/blocker/basic_blocker.lua",
			widget_class = require("example.examples.basic.blocker.basic_blocker"),
		},
		--- 返回键处理示例
		{
			name_id = "ui_example_basic_back_handler",
			information_text_id = "ui_example_basic_back_handler_description",
			template = "basic_back_handler",
			root = "basic_back_handler/root",
			code_url = "example/examples/basic/back_handler/basic_back_handler.lua",
			widget_class = require("example.examples.basic.back_handler.basic_back_handler"),
		},
		--- 计时器示例
		{
			name_id = "ui_example_basic_timer",
			information_text_id = "ui_example_basic_timer_description",
			template = "basic_timer",
			root = "basic_timer/root",
			code_url = "example/examples/basic/timer/basic_timer.lua",
			widget_class = require("example.examples.basic.timer.basic_timer"),
		},
		--- 快捷键示例
		{
			name_id = "ui_example_basic_hotkey",
			information_text_id = "ui_example_basic_hotkey_description",
			template = "basic_hotkey",
			root = "basic_hotkey/root",
			code_url = "example/examples/basic/hotkey/basic_hotkey.lua",
			widget_class = require("example.examples.basic.hotkey.basic_hotkey"),
		},
		--- 滚动视图示例
		{
			name_id = "ui_example_basic_scroll",
			information_text_id = "ui_example_basic_scroll_description",
			template = "scroll",
			root = "scroll/root",
			code_url = "example/examples/basic/scroll/scroll.lua",
			widget_class = require("example.examples.basic.scroll.scroll"),
		},
		--- 带滑块滚动视图示例
		{
			name_id = "ui_example_basic_scroll_slider",
			information_text_id = "ui_example_basic_scroll_slider_description",
			template = "scroll_slider",
			root = "scroll_slider/root",
			code_url = "example/examples/basic/scroll_slider/scroll_slider.lua",
			widget_class = require("example.examples.basic.scroll_slider.scroll_slider"),
		},
		--- 网格布局示例
		{
			name_id = "ui_example_basic_grid",
			information_text_id = "ui_example_basic_grid_description",
			template = "grid",
			root = "grid/root",
			code_url = "example/examples/basic/grid/grid.lua",
			widget_class = require("example.examples.basic.grid.grid"),
		},
		--- 滚动绑定网格示例
		{
			name_id = "ui_example_basic_scroll_bind_grid",
			information_text_id = "ui_example_basic_scroll_bind_grid_description",
			template = "scroll_bind_grid",
			root = "scroll_bind_grid/root",
			code_url = "example/examples/basic/scroll_bind_grid/scroll_bind_grid.lua",
			widget_class = require("example.examples.basic.scroll_bind_grid.scroll_bind_grid"),
		},
		--- 水平滚动绑定网格示例
		{
			name_id = "ui_example_basic_scroll_bind_grid_horizontal",
			information_text_id = "ui_example_basic_scroll_bind_grid_horizontal_description",
			template = "scroll_bind_grid_horizontal",
			root = "scroll_bind_grid_horizontal/root",
			code_url = "example/examples/basic/scroll_bind_grid/scroll_bind_grid_horizontal.lua",
			widget_class = require("example.examples.basic.scroll_bind_grid.scroll_bind_grid_horizontal"),
		},
		--- 滚动绑定网格（锚点定位）示例
		{
			name_id = "ui_example_basic_scroll_bind_grid_points",
			information_text_id = "ui_example_basic_scroll_bind_grid_points_description",
			template = "scroll_bind_grid_points",
			root = "scroll_bind_grid_points/root",
			code_url = "example/examples/basic/scroll_bind_grid/scroll_bind_grid_points.lua",
			widget_class = require("example.examples.basic.scroll_bind_grid.scroll_bind_grid_points"),
		},
		--- 输入框示例
		{
			name_id = "ui_example_basic_input",
			information_text_id = "ui_example_basic_input_description",
			template = "basic_input",
			root = "basic_input/root",
			code_url = "example/examples/basic/input/basic_input.lua",
			widget_class = require("example.examples.basic.input.basic_input"),
		},
		--- 密码输入框示例
		{
			name_id = "ui_example_input_password",
			information_text_id = "ui_example_input_password_description",
			template = "input_password",
			root = "input_password/root",
			code_url = "example/examples/basic/input/input_password.lua",
			widget_class = require("example.examples.basic.input.input_password"),
		},
		--- 富文本输入框示例
		{
			name_id = "ui_example_basic_rich_input",
			information_text_id = "ui_example_basic_rich_input_description",
			template = "basic_rich_input",
			root = "basic_rich_input/root",
			code_url = "example/examples/basic/input/rich_input.lua",
			widget_class = require("example.examples.basic.input.rich_input"),
		},
		--- 富文本示例
		{
			name_id = "ui_example_basic_rich_text",
			information_text_id = "ui_example_basic_rich_text_description",
			template = "basic_rich_text",
			root = "basic_rich_text/root",
			code_url = "example/examples/basic/rich_text/basic_rich_text.lua",
			widget_class = require("example.examples.basic.rich_text.basic_rich_text"),
		},
		--- 富文本标签示例
		{
			name_id = "ui_example_rich_text_tags",
			information_text_id = "ui_example_rich_text_tags_description",
			template = "rich_text_tags",
			root = "rich_text_tags/root",
			code_url = "example/examples/basic/rich_text/rich_text_tags.lua",
			widget_class = require("example.examples.basic.rich_text.rich_text_tags"),
		},
		--- 富文本分割动画示例
		{
			name_id = "ui_example_rich_text_split_animated",
			information_text_id = "ui_example_rich_text_split_animated_description",
			template = "rich_text_split_animated",
			root = "rich_text_split_animated/root",
			code_url = "example/examples/basic/rich_text/rich_text_split_animated.lua",
			widget_class = require("example.examples.basic.rich_text.rich_text_split_animated"),
		},
		--- 富文本自适应大小示例
		{
			name_id = "ui_example_rich_text_resize",
			information_text_id = "ui_example_rich_text_resize_description",
			template = "rich_text_resize",
			root = "rich_text_resize/root",
			code_url = "example/examples/basic/rich_text/rich_text_resize.lua",
			widget_class = require("example.examples.basic.rich_text.rich_text_resize"),
		},
		-- 自定义富文本标签示例（已注释）
		--{
		--	name_id = "ui_example_rich_text_tags_custom",
		--	information_text_id = "ui_example_rich_text_tags_custom_description",
		--	template = "rich_text_tags_custom",
		--	root = "rich_text_tags_custom/root",
		--	code_url = "example/examples/basic/rich_text/rich_text_tags_custom.lua",
		--	component_class = require("example.examples.basic.rich_text.rich_text_tags_custom"),
		--	properties_control = function(instance, properties_panel)
		--		local pivot_index = 1
		--		local pivot_list = {
		--			gui.PIVOT_CENTER,
		--			gui.PIVOT_W,
		--			gui.PIVOT_SW,
		--			gui.PIVOT_S,
		--			gui.PIVOT_SE,
		--			gui.PIVOT_E,
		--			gui.PIVOT_NE,
		--			gui.PIVOT_N,
		--			gui.PIVOT_NW,
		--		}

		--		---@cast instance rich_text_tags_custom
		--		properties_panel:add_button("ui_pivot_next", function()
		--			pivot_index = pivot_index + 1
		--			if pivot_index > #pivot_list then
		--				pivot_index = 1
		--			end
		--			instance:set_pivot(pivot_list[pivot_index])
		--		end)
		--	end,

		--	on_create = function(instance, output_log)
		--		---@cast instance rich_text_tags_custom
		--		instance.on_link_click:subscribe(function(text)
		--			output_log:add_log_text("自定义链接: " .. text)
		--		end)
		--	end
		--},
		--- 滑动手势示例
		{
			name_id = "ui_example_basic_swipe",
			information_text_id = "ui_example_basic_swipe_description",
			template = "basic_swipe",
			root = "basic_swipe/root",
			code_url = "example/examples/basic/swipe/basic_swipe.lua",
			widget_class = require("example.examples.basic.swipe.basic_swipe"),
		},
		--- 复选框示例
		{
			name_id = "ui_example_checkbox",
			information_text_id = "ui_example_checkbox_description",
			template = "checkbox",
			root = "checkbox/root",
			code_url = "example/examples/basic/checkbox/checkbox.lua",
			widget_class = require("example.examples.basic.checkbox.checkbox"),
		},
		--- 复选框组示例
		{
			name_id = "ui_example_checkbox_group",
			information_text_id = "ui_example_checkbox_group_description",
			template = "checkbox_group",
			root = "checkbox_group/root",
			code_url = "example/examples/basic/checkbox_group/checkbox_group.lua",
			widget_class = require("example.examples.basic.checkbox_group.checkbox_group"),
		},
		--- 单选按钮组示例
		{
			name_id = "ui_example_radio_group",
			information_text_id = "ui_example_radio_group_description",
			template = "radio_group",
			root = "radio_group/root",
			code_url = "example/examples/basic/radio_group/radio_group.lua",
			widget_class = require("example.examples.basic.radio_group.radio_group"),
		},
	}
end

return M
