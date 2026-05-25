local panthera = require("panthera.panthera")
local intro_panthera = require("example.examples.intro.intro.intro_panthera")

---@class examples.intro: druid.widget
---@field root node
---@field animation panthera.animation
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

	-- 创建并播放Panthera动画，设置为循环播放
	self.animation = panthera.create_gui(intro_panthera, self:get_template(), self:get_nodes())
	panthera.play(self.animation, "idle", { is_loop = true })
end

--- 打开外部链接
---@param link string 要打开的URL地址
function M:open_link(link)
	sys.open_url(link, { target = "_blank" })
end

--- 组件移除时停止动画
function M:on_remove()
	panthera.stop(self.animation)
end

return M
