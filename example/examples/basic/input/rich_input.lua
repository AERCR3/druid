--- 富文本输入框示例：展示富文本输入框的使用
---@class examples.rich_input: druid.widget
---@field rich_input druid.rich_input
---@field rich_input_2 druid.rich_input
local M = {}


--- 初始化函数：创建两个富文本输入框，设置占位符
function M:init()
	self.rich_input = self.druid:new_rich_input("rich_input") --[[@as druid.rich_input]]
	self.rich_input:set_placeholder("输入文本...")

	self.rich_input_2 = self.druid:new_rich_input("rich_input_2") --[[@as druid.rich_input]]
	self.rich_input_2:set_placeholder("输入文本...")
end

--- 示例创建回调：订阅输入框取消选中事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	self.rich_input.input.on_input_unselect:subscribe(function(_, text)
		output_log:add_log_text("输入框1: " .. text)
	end)
	self.rich_input_2.input.on_input_unselect:subscribe(function(_, text)
		output_log:add_log_text("输入框2: " .. text)
	end)
end

return M
