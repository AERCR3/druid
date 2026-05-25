local event = require("event.event")

--- 计时器示例：展示循环计时器，每次周期结束后自动增加5秒
---@class examples.basic_timer: druid.widget
---@field root node
---@field text druid.text
local M = {}

--- 初始化函数：创建计时器，设置初始5秒倒计时，周期结束后自动加5秒
function M:init()
	self.root = self:get_node("root")
	self.timer = self.druid:new_timer("text")

	-- 设置初始时间为5秒，倒计时到0
	local time = 5
	self.timer:set_interval(time, 0)
	-- 倒计时结束时，增加5秒并触发周期结束事件
	self.timer.on_timer_end:subscribe(function()
		time = time + 5
		self.timer:set_interval(time, 0)
		self.on_cycle_end:trigger()
	end)

	-- 创建周期结束事件
	self.on_cycle_end = event.create()
end

---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅计时器周期结束事件并记录日志
	self.on_cycle_end:subscribe(function()
		output_log:add_log_text("计时器周期结束")
	end)
end

return M
