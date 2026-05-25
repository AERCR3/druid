local event = require("event.event")

-- 复用 checkbox 示例里的组件实现
local checkbox = require("example.examples.basic.checkbox.checkbox")

--- 复选框组示例：展示多个复选框的分组状态管理
---@class examples.checkbox_group: druid.widget
---@field checkbox_1 examples.checkbox
---@field checkbox_2 examples.checkbox
---@field checkbox_3 examples.checkbox
local M = {}


--- 初始化函数：创建三个复选框并订阅状态改变事件
function M:init()
	self.checkbox_1 = self.druid:new_widget(checkbox, "checkbox_1")
	self.checkbox_2 = self.druid:new_widget(checkbox, "checkbox_2")
	self.checkbox_3 = self.druid:new_widget(checkbox, "checkbox_3")

	self.checkbox_1.on_state_changed:subscribe(self.on_checkbox_click, self)
	self.checkbox_2.on_state_changed:subscribe(self.on_checkbox_click, self)
	self.checkbox_3.on_state_changed:subscribe(self.on_checkbox_click, self)

	self.on_state_changed = event.create()
end

--- 复选框点击回调：打印所有复选框状态并触发分组状态改变事件
function M:on_checkbox_click()
	-- 打印所有复选框的当前状态
	print("复选框1: ", self.checkbox_1:get_state())
	print("复选框2: ", self.checkbox_2:get_state())
	print("复选框3: ", self.checkbox_3:get_state())

	-- 触发状态改变事件，传递三个复选框的状态
	self.on_state_changed:trigger(self.checkbox_1:get_state(), self.checkbox_2:get_state(), self.checkbox_3:get_state())
end

--- 示例创建回调：订阅状态改变事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅状态改变事件，记录所有复选框的状态
	self.on_state_changed:subscribe(function(state1, state2, state3)
		output_log:add_log_text("状态: " .. tostring(state1) .. " " .. tostring(state2) .. " " .. tostring(state3))
	end)
end

return M
