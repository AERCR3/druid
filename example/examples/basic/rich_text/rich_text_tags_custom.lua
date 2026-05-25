local helper = require("druid.helper")
local event = require("event.event")

--- 富文本自定义标签示例：展示自定义链接、字符拆分和混合标签
---@class examples.rich_text_tags_custom: druid.widget
---@field rich_text_link druid.rich_text
---@field rich_text_characters druid.rich_text
---@field rich_text_custom druid.rich_text
---@field position table 各富文本的初始位置
---@field on_link_click event 链接点击事件
local M = {}


--- 初始化函数：创建三种自定义标签的富文本示例（链接、字符拆分、混合标签）
function M:init()
	do -- 初始化富文本链接示例：把自定义标签包裹的单词节点转换成可点击按钮
		self.rich_text_link = self.druid:new_rich_text("rich_text_link") --[[@as druid.rich_text]]
		-- 设置富文本内容，包含自定义链接标签
		self.rich_text_link:set_text("你好，我是一个<custom_link><color=A1D7F5>自定义链接</color></custom_link>")

		-- 获取自定义标签包裹的所有单词节点，并为每个节点创建可点击按钮
		local tagged = self.rich_text_link:tagged("custom_link")
		for index = 1, #tagged do
			local word = tagged[index]
			-- 点击链接时触发链接点击事件
			self.druid:new_button(word.node, function()
				self.on_link_click:trigger(word.text)
			end)
		end
	end

	-- 字符拆分富文本示例：文本中的每个字符会被拆分为独立节点
	self.rich_text_characters = self.druid:new_rich_text("rich_text_characters") --[[@as druid.rich_text]]
	-- 设置拆分字符的富文本示例
	self.rich_text_characters:set_text("你好，我的字符被拆分了")

	-- 混合标签富文本示例：不同大小和字体的组合
	self.rich_text_custom = self.druid:new_rich_text("rich_text_custom") --[[@as druid.rich_text]]
	-- 设置包含不同大小和字体的富文本示例
	self.rich_text_custom:set_text(
		"你好，我有<size=1.25><font=text_bold>南部文本锚点</font></size>来调整<size=0.75><font=text_bold>不同的文本缩放</font></size>")

	-- 保存各富文本的初始位置，用于锚点切换时计算偏移
	self.position = {
		[self.rich_text_link] = gui.get_position(self.rich_text_link.root),
		[self.rich_text_characters] = gui.get_position(self.rich_text_characters.root),
		[self.rich_text_custom] = gui.get_position(self.rich_text_custom.root),
	}

	-- 创建链接点击事件
	self.on_link_click = event.create()
end

--- 设置锚点：根据锚点偏移量调整所有富文本的位置
---@param pivot number 锚点常量
function M:set_pivot(pivot)
	-- 获取锚点偏移量
	local pivot_offset = helper.get_pivot_offset(pivot)
	-- 收集所有富文本实例
	local rich_texts = {
		self.rich_text_link,
		self.rich_text_characters,
		self.rich_text_custom,
	}

	-- 遍历所有富文本，根据锚点偏移调整位置并重新布局
	for _, rich_text in ipairs(rich_texts) do
		gui.set_pivot(rich_text.root, pivot)
		local pos = self.position[rich_text]
		local size_x = gui.get(rich_text.root, "size.x")
		local size_y = gui.get(rich_text.root, "size.y")
		local offset_x = size_x * pivot_offset.x
		local offset_y = size_y * pivot_offset.y
		gui.set_position(rich_text.root, vmath.vector3(pos.x + offset_x, pos.y + offset_y, pos.z))
		rich_text:set_text(rich_text:get_text())
	end
end

return M
