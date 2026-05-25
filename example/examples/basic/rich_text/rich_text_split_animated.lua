--- 字符拆分动画示例：将富文本拆分为单个字符并添加浮动动画
---@class examples.rich_text_split_animated: druid.widget
---@field rich_text druid.rich_text
local M = {}

-- 字符浮动的偏移量（像素）
local OFFSET = 20

--- 初始化函数：创建富文本并启动字符动画
function M:init()
	-- 创建富文本组件
	self.rich_text = self.druid:new_rich_text("text")
	-- 启用字符拆分模式，使每个字符成为独立节点
	self.rich_text:set_split_to_characters(true)
	-- 设置带颜色的富文本内容
	self.rich_text:set_text("<color=#E48155>Hello</color> <color=#A1D7F5>World</color>!")

	-- 启动字符浮动动画
	self:_animate_letters()
end

--- 为每个字符添加上下浮动的 ping-pong 动画
function M:_animate_letters()
	-- 获取所有单词节点
	local words = self.rich_text:get_words()
	if not words then
		return
	end

	-- 遍历每个单词/字符节点，添加浮动动画
	for i = 1, #words do
		local word = words[i]
		-- 只对非图片类型的文本节点添加动画
		if word.node and not word.image then
			-- 使用 ping-pong 循环播放，让字符在原始位置和偏移位置之间来回浮动
			gui.animate(word.node, "position.y", word.position.y + OFFSET, gui.EASING_INOUTQUAD, 1, (i - 1) * 0.09, nil,
				gui.PLAYBACK_LOOP_PINGPONG)
		end
	end
end

return M
