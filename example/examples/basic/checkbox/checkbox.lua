local event = require("event.event")

--- 复选框示例：展示复选框的勾选/取消勾选功能
---@class examples.checkbox: druid.widget
---@field button druid.button
---@field is_enabled boolean
local M = {}


--- 初始化函数：创建按钮、图标和选中效果，初始化状态事件
function M:init()
	self.button = self.druid:new_button("root", self.on_checkbox_click) -- 用于处理勾选点击的按钮
	self.icon = self:get_node("icon")                                  -- 复选框图标（显示/隐藏）
	self.selected = self:get_node("selected")                          -- 勾选变化时的选中效果
	gui.set_alpha(self.selected, 0)

	self:set_state(false)

	self.on_state_changed = event.create()
end

--- 复选框点击回调：切换勾选状态并触发事件
function M:on_checkbox_click()
	self:set_state(not self.is_enabled)
	self.on_state_changed:trigger(self.is_enabled)
end

--- 设置勾选状态：更新图标显示和选中动画
---@param is_enabled boolean 是否勾选
function M:set_state(is_enabled)
	if self.is_enabled == is_enabled then
		return
	end

	self.is_enabled = is_enabled
	gui.set_enabled(self.icon, self.is_enabled)

	gui.set_alpha(self.selected, 1)
	gui.animate(self.selected, "color.w", 0, gui.EASING_INSINE, 0.16)
end

--- 获取当前勾选状态
---@return boolean
function M:get_state()
	return self.is_enabled
end

---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅复选框点击事件，记录复选框的状态
	self.button.on_click:subscribe(function()
		output_log:add_log_text("复选框已点击: " .. tostring(self.is_enabled))
	end)
end

return M
