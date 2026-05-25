--- 双击按钮示例：展示按钮的单击和双击事件处理
---@class examples.basic_button_double_click: druid.widget
---@field button druid.button
local M = {}


--- 初始化函数：创建按钮并订阅单击和双击事件
function M:init()
	-- 创建按钮并设置单击回调
	self.button = self.druid:new_button("button/root", function()
		print("点击")
	end)

	-- 订阅双击事件
	self.button.on_double_click:subscribe(function()
		print("双击")
	end)
end

--- 示例创建回调：订阅单击和双击事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅单击事件并记录日志
	self.button.on_click:subscribe(function()
		output_log:add_log_text("已点击")
	end)
	-- 订阅双击事件并记录日志
	self.button.on_double_click:subscribe(function()
		output_log:add_log_text("已双击")
	end)
end

return M
