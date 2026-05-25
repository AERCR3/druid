--- 属性按钮组件：属性面板中的按钮控件，点击时触发回调并显示选中效果
---@class property_button: druid.widget
---@field root node
---@field text_name druid.lang_text
---@field button druid.button
---@field text_button druid.text
local M = {}


--- 初始化函数：创建按钮组件和文本标签
function M:init()
	self.root = self:get_node("root")
	self.text_name = self.druid:new_lang_text("text_name") --[[@as druid.lang_text]]
	self.selected = self:get_node("selected")
	gui.set_alpha(self.selected, 0)

	self.button = self.druid:new_button("button", self.on_click)
	self.text_button = self.druid:new_text("text_button")
end

--- 点击回调：显示选中效果并逐渐淡出
function M:on_click()
	gui.set_alpha(self.selected, 1)
	gui.animate(self.selected, "color.w", 0, gui.EASING_INSINE, 0.16)
end

return M
