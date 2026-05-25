--- 富文本标签示例：展示富文本的颜色、字体、大小、换行和图片标签
---@class examples.rich_text_tags: druid.widget
---@field rich_text_color druid.rich_text
---@field rich_text_font druid.rich_text
---@field rich_text_size druid.rich_text
---@field rich_text_breaks druid.rich_text
---@field rich_text_image druid.rich_text
local M = {}


--- 初始化函数：创建五种不同标签类型的富文本示例
function M:init()
	-- 颜色标签示例：嵌套颜色标签
	self.rich_text_color = self.druid:new_rich_text("rich_text_color") --[[@as druid.rich_text]]
	self.rich_text_color:set_text(
	"Hello, I'm a <color=E48155>Rich Text</color> and it's <color=8ED59E>nested <color=A1D7F5>color</color> tag</color>")

	-- 字体标签示例：粗体和嵌套颜色字体
	self.rich_text_font = self.druid:new_rich_text("rich_text_font") --[[@as druid.rich_text]]
	self.rich_text_font:set_text(
	"Hello, I'm a <font=text_bold>Rich Text</font> and this is <font=text_bold><color=8ED59E>bold text</color></font>")

	-- 大小标签示例：不同缩放的文本
	self.rich_text_size = self.druid:new_rich_text("rich_text_size") --[[@as druid.rich_text]]
	self.rich_text_size:set_text(
	"Hello, I'm have <size=1.15><font=text_bold>East Pivot</font></size> and <size=0.85><font=text_bold>different text scale</font></size>")

	-- 换行标签示例：使用 <br/> 标签和 \n 换行
	self.rich_text_breaks = self.druid:new_rich_text("rich_text_breaks") --[[@as druid.rich_text]]
	self.rich_text_breaks:set_text("Hello, I'm Rich Text<br/>With \"<color=E6DF9F>Line Breaks</color>\"\nEnabled in GUI")

	-- 图片标签示例：在文本中嵌入图片
	self.rich_text_image = self.druid:new_rich_text("rich_text_image") --[[@as druid.rich_text]]
	self.rich_text_image:set_text(
	"Hello, I'm<img=druid_example:icon_cross,32/>Rich Text <img=druid_logo:icon_druid,48/> <color=8ED59E><img=druid_logo:icon_druid,48/></color> <color=F49B9B><img=druid_logo:icon_druid,48/></color>")
end

--- 设置锚点：将所有富文本的锚点设置为指定值
---@param pivot number 锚点常量
function M:set_pivot(pivot)
	-- 收集所有富文本实例
	local rich_texts = {
		self.rich_text_color,
		self.rich_text_font,
		self.rich_text_size,
		self.rich_text_breaks,
		self.rich_text_image,
	}
	-- 遍历并设置每个富文本的锚点
	for _, rich_text in ipairs(rich_texts) do
		rich_text:set_pivot(pivot)
	end
end

--- 属性面板控制：添加锚点切换按钮
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	-- 锚点列表和索引
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

	-- 循环切换锚点位置按钮
	properties_panel:add_button("ui_pivot_next", function()
		pivot_index = pivot_index + 1
		if pivot_index > #pivot_list then
			pivot_index = 1
		end
		self:set_pivot(pivot_list[pivot_index])
	end)
end

return M
