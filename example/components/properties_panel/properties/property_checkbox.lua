---@class property_checkbox: druid.widget
---@field root druid.container
---@field text_name druid.lang_text
---@field button druid.button
---@field selected node
local M = {}


--- 初始化函数：创建容器、图标、选中效果和按钮
function M:init()
	self.root = self.druid:new_container("root") --[[@as druid.container]]

	self.icon = self:get_node("icon")
	gui.set_enabled(self.icon, false)

	self.selected = self:get_node("selected")
	gui.set_alpha(self.selected, 0)

	self.text_name = self.druid:new_lang_text("text_name") --[[@as druid.lang_text]]

	self.button = self.druid:new_button("button", self.on_click)
end

--- 设置复选框值：更新勾选状态，可选择是否显示动画效果
---@param value boolean 是否勾选
---@param is_instant boolean 是否立即设置（无动画）
function M:set_value(value, is_instant)
	if self._value == value then
		return
	end

	self._value = value
	gui.set_enabled(self.icon, value)

	if not is_instant then
		gui.set_alpha(self.selected, 1)
		gui.animate(self.selected, "color.w", 0, gui.EASING_INSINE, 0.16)
	end
end

--- 获取当前勾选状态
---@return boolean 当前是否勾选
function M:get_value()
	return self._value
end

--- 点击回调：切换勾选状态
function M:on_click()
	self:set_value(not self:get_value())
end

return M
