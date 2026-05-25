--- 富文本自适应大小示例：展示富文本区域的宽高调整和锚点切换
---@class examples.rich_text_resize: druid.widget
---@field rich_text druid.rich_text
local M = {}

--- 文本区域最小宽度
local WIDTH_MIN = 80
--- 文本区域最大宽度
local WIDTH_MAX = 600
--- 文本区域最小高度
local HEIGHT_MIN = 60
--- 文本区域最大高度
local HEIGHT_MAX = 520

--- 长文本内容：包含颜色和字体标签，用于演示富文本自动换行和缩放
local LONG_TEXT =
		"This is a <color=E48155>long rich text</color> example. You can resize the text area using the sliders on the right. "
		.. "The text will <font=text_bold>wrap and adjust</font> to fit within the new width and height. "
		.. "Try making the area smaller to see how <color=8ED59E>multiline rich text</color> scales and fits. "
		.. "The adjust_to_area feature will scale down the text if it does not fit in the available space."


--- 初始化函数：创建富文本并设置长文本内容，同时显示调试区域
function M:init()
	-- 创建富文本并设置内容
	self.rich_text = self.druid:new_rich_text("text") --[[@as druid.rich_text]]
	self.rich_text:set_text(LONG_TEXT)

	-- 显示文本区域调试边框
	self.node_text_area_debug = self:get_node("text_area_debug")
	gui.set_size(self.node_text_area_debug, vmath.vector3(gui.get_size(self.rich_text.root)))
end

--- 属性面板控制：添加宽度/高度滑块和锚点切换按钮
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	-- 计算当前尺寸的归一化值，用于滑块初始位置
	local size = gui.get_size(self.rich_text.root)
	local width_norm = (size.x - WIDTH_MIN) / (WIDTH_MAX - WIDTH_MIN)
	local height_norm = (size.y - HEIGHT_MIN) / (HEIGHT_MAX - HEIGHT_MIN)

	-- 宽度滑块：调整文本区域宽度
	properties_panel:add_slider("ui_width", width_norm, function(value)
		local w = math.floor(WIDTH_MIN + value * (WIDTH_MAX - WIDTH_MIN))
		local s = gui.get_size(self.rich_text.root)
		gui.set_size(self.rich_text.root, vmath.vector3(w, s.y, 0))
		-- 重新设置文本以触发重新布局
		self.rich_text:set_text(self.rich_text:get_text())
		gui.set_size(self.node_text_area_debug, vmath.vector3(w, s.y, 0))
	end)

	-- 高度滑块：调整文本区域高度
	properties_panel:add_slider("ui_height", height_norm, function(value)
		local h = math.floor(HEIGHT_MIN + value * (HEIGHT_MAX - HEIGHT_MIN))
		local s = gui.get_size(self.rich_text.root)
		gui.set_size(self.rich_text.root, vmath.vector3(s.x, h, 0))
		-- 重新设置文本以触发重新布局
		self.rich_text:set_text(self.rich_text:get_text())
		gui.set_size(self.node_text_area_debug, vmath.vector3(s.x, h, 0))
	end)

	-- 锚点切换按钮：循环切换富文本的锚点位置
	local pivot_index = 1
	local pivot_list = {
		gui.PIVOT_CENTER,
		gui.PIVOT_W,
		gui.PIVOT_SW,
		gui.PIVOT_S,
		gui.PIVOT_SE,
		gui.PIVOT_E,
		gui.PIVOT_NE,
		gui.PIVOT_N,
		gui.PIVOT_NW,
	}
	properties_panel:add_button("ui_pivot_next", function()
		pivot_index = pivot_index + 1
		if pivot_index > #pivot_list then
			pivot_index = 1
		end
		-- 切换到下一个锚点位置
		self.rich_text:set_pivot(pivot_list[pivot_index])
	end)
end

return M
