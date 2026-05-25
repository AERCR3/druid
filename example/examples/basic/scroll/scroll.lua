local component = require("druid.component")

--- 滚动视图示例：展示滚动视图的属性控制（弹性、裁剪、摩擦力、速度等）
---@class examples.scroll: druid.widget
---@field root node
---@field scroll druid.scroll
local M = {}

--- 初始化函数：创建滚动视图和两个按钮
function M:init()
	self.scroll = self.druid:new_scroll("scroll_view", "scroll_content")

	self.button_tutorial = self.druid:new_button("button_tutorial/root")
	self.button_stencil = self.druid:new_button("button_stencil/root")
end

--- 示例创建回调：订阅按钮点击事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅教程按钮点击事件
	self.button_tutorial.on_click:subscribe(function()
		output_log:add_log_text("教程按钮已点击")
	end)
	-- 订阅模板按钮点击事件
	self.button_stencil.on_click:subscribe(function()
		output_log:add_log_text("模板按钮已点击")
	end)
end

--- 属性面板控制：添加滚动视图的各种属性控件
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	local scroll = self.scroll
	-- 弹性滚动开关
	local is_stretch = self.scroll.style.EXTRA_STRETCH_SIZE > 0
	properties_panel:add_checkbox("ui_elastic_scroll", is_stretch, function(value)
		self.scroll:set_extra_stretch_size(value and 100 or 0)
	end)

	-- 裁剪模式开关
	local view_node = self.scroll.view_node
	local is_stencil = gui.get_clipping_mode(view_node) == gui.CLIPPING_MODE_STENCIL
	properties_panel:add_checkbox("ui_clipping", is_stencil, function(value)
		gui.set_clipping_mode(view_node, value and gui.CLIPPING_MODE_STENCIL or gui.CLIPPING_MODE_NONE)
	end)

	-- 摩擦力滑块：控制滚动减速速度
	local slider_frict = properties_panel:add_slider("ui_slider_friction", 0, function(value)
		scroll.style.FRICT = 1 - ((1 - value) * 0.1)
	end)
	slider_frict:set_text_function(function(value)
		return string.format("%.2f", 1 - ((1 - value) * 0.1))
	end)
	slider_frict:set_value(1 - (1 - scroll.style.FRICT) / 0.1)

	-- 惯性速度滑块：控制滚动的惯性速度
	local slider_speed = properties_panel:add_slider("ui_slider_speed", 0, function(value)
		scroll.style.INERT_SPEED = value * 50
	end)
	slider_speed:set_value(scroll.style.INERT_SPEED / 50)
	slider_speed:set_text_function(function(value)
		return string.format("%.1f", value * 50)
	end)

	-- 滚轮速度滑块：控制鼠标滚轮滚动速度
	local slider_wheel_speed = properties_panel:add_slider("ui_slider_wheel_speed", 0, function(value)
		scroll.style.WHEEL_SCROLL_SPEED = value * 30
	end)
	slider_wheel_speed:set_value(scroll.style.WHEEL_SCROLL_SPEED / 30)
	slider_wheel_speed:set_text_function(function(value)
		return string.format("%.1f", value * 30)
	end)

	-- 滚轮惯性开关：滚轮滚动是否作为惯性处理
	local wheel_by_inertion = properties_panel:add_checkbox("ui_wheel_by_inertion", scroll.style.WHEEL_SCROLL_BY_INERTION,
		function(value)
			scroll.style.WHEEL_SCROLL_BY_INERTION = value
		end)
	wheel_by_inertion:set_value(scroll.style.WHEEL_SCROLL_BY_INERTION)
end

--- 获取调试信息：返回滚动视图的尺寸和位置信息
---@return string
function M:get_debug_info()
	local info = ""

	local s = self.scroll
	-- 构建滚动视图的调试信息
	info = info .. "视图大小 Y: " .. gui.get(s.view_node, "size.y") .. "\n"
	info = info .. "内容大小 Y: " .. gui.get(s.content_node, "size.y") .. "\n"
	info = info .. "内容位置 Y: " .. math.ceil(s.position.y) .. "\n"
	info = info .. "内容范围 Y: " .. s.available_pos.y .. " - " .. s.available_pos.w .. "\n"

	return info
end

return M
