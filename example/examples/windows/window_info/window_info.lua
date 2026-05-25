local panthera = require("panthera.panthera")

local window_animation_panthera = require("example.examples.windows.window_animation_panthera")

--- 信息窗口示例：展示带打开/关闭动画的信息对话框
---@class examples.window_info: druid.widget
---@field text_header druid.lang_text
---@field text_button_accept druid.lang_text
---@field text_description druid.lang_text
---@field button_close druid.button
---@field button_accept druid.button
---@field animation panthera.animation
local M = {}


--- 初始化函数：创建本地化文本、按钮和窗口动画
function M:init()
	-- 创建标题、接受按钮文本和描述文本（本地化）
	self.text_header = self.druid:new_lang_text("text_header", "ui_information") --[[@as druid.lang_text]]
	self.text_button_accept = self.druid:new_lang_text("button_accept/text", "ui_accept") --[[@as druid.lang_text]]
	self.text_description = self.druid:new_lang_text("text") --[[@as druid.lang_text]]

	-- 创建关闭按钮和接受按钮
	self.button_close = self.druid:new_button("button_close", self.on_button_close)
	self.button_accept = self.druid:new_button("button_accept/root")

	-- 创建并播放窗口打开动画
	self.animation = panthera.create_gui(window_animation_panthera, self:get_template(), self:get_nodes())
	panthera.play(self.animation, "open")
end

--- 关闭按钮回调：播放窗口关闭动画
function M:on_button_close()
	panthera.play(self.animation, "close")
end

---@param output_list output_list
function M:on_example_created(output_list)
	self.text_header:translate("ui_information")
	self.text_button_accept:translate("ui_confirm")
	self.text_description:translate("ui_example_window_information_text")

	-- 订阅接受按钮点击事件并记录日志
	self.button_accept.on_click:subscribe(function()
		output_list:add_log_text("信息已接受")
	end)
end

return M
