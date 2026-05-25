---@class examples.how_to_use_example: druid.widget
---@field root node
local M = {}


function M:init()
	self.root = self:get_node("root")

	-- 创建富文本，展示彩色文本效果
	self.druid:new_rich_text("text_hello", "He<color=#E48155>ll</color>o!")

	-- 创建赞助链接按钮
	self.druid:new_button("sponsor_github", self.open_link, "https://github.com/sponsors/insality")
	self.druid:new_button("sponsor_coffee", self.open_link, "https://www.buymeacoffee.com/insality")
	self.druid:new_button("sponsor_kofi", self.open_link, "https://ko-fi.com/insality")

	-- 使用布局管理器排列赞助按钮，设置水平间距为8像素
	self.druid:new_layout("sponsor")
			:add("sponsor_github")
			:add("sponsor_coffee")
			:add("sponsor_kofi")
			:set_margin(8, 0)
end

--- 打开外部链接
---@param link string 要打开的URL地址
function M:open_link(link)
	sys.open_url(link, { target = "_blank" })
end

return M
