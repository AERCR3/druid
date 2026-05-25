local event = require("event.event")

-- 复用 checkbox 示例里的组件实现
local checkbox = require("example.examples.basic.checkbox.checkbox")

--- 单选组示例：展示单选按钮分组功能，同一时间只有一个选项被选中
---@class examples.radio_group: druid.widget
---@field checkboxes examples.checkbox[]
---@field state boolean[]
local M = {}


--- 初始化函数：创建三个复选框并初始选中第一个
function M:init()
	self.state = {}
	self.checkboxes = {
		self.druid:new_widget(checkbox, "checkbox_1"),
		self.druid:new_widget(checkbox, "checkbox_2"),
		self.druid:new_widget(checkbox, "checkbox_3")
	}

	for i = 1, #self.checkboxes do
		self.checkboxes[i].on_state_changed:subscribe(self.on_checkbox_click, self)
		self.state[i] = false
	end

	self.checkboxes[1]:set_state(true)
	self.state[1] = true

	self.on_state_changed = event.create()
end

--- 复选框点击回调：确保只有一个复选框被选中（单选逻辑）
function M:on_checkbox_click()
	local new_clicked = nil
	for index = 1, #self.checkboxes do
		if self.checkboxes[index]:get_state() ~= self.state[index] then
			new_clicked = index
			break
		end
	end

	for index = 1, #self.state do
		self.checkboxes[index]:set_state(index == new_clicked)
		self.state[index] = index == new_clicked
	end

	self.on_state_changed:trigger(new_clicked)
end

--- 示例创建回调：订阅选中事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	self.on_state_changed:subscribe(function(selected)
		output_log:add_log_text("选中项: " .. selected)
	end)
end

return M
