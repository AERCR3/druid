--- 富文本基础示例：展示富文本的基本用法，支持字体和颜色标签
---@class examples.basic_rich_text: druid.widget
---@field rich_text druid.rich_text
local M = {}


--- 初始化函数：创建富文本并设置带标签的文本内容
function M:init()
	self.rich_text = self.druid:new_rich_text("text",
		"Hello, I'm a <font=text_bold><color=E48155>Rich Text</font></color>!")
end

return M
