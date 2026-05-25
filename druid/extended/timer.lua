local event = require("event.event")
local helper = require("druid.helper")
local component = require("druid.component")

---Druid组件，用于处理GUI文本节点上的计时器工作。以格式化的方式显示时间。
---
---### 设置
---使用druid创建计时器组件: `timer = druid:new_timer(text_node, from_seconds, to_seconds, callback)`
---
---### 注意事项
---- 当计时器值等于_to_seconds_时，计时器触发回调
---- 计时器将使用当前计时器值设置文本节点
---- 计时器使用更新函数来处理时间
---计时器组件用于在UI中显示倒计时或正计时，支持格式化显示
---@class druid.timer: druid.component
---@field on_tick event fun(context, value) 计时器滴答时触发的事件
---@field on_set_enabled event fun(context, is_on) 计时器启用时触发的事件
---@field on_timer_end event fun(context) 计时器结束时触发的事件
---@field node node 显示计时器的节点
---@field from number 计时器的开始时间
---@field target number 计时器的目标时间
---@field value number 计时器的当前值
---@field is_on boolean|nil 如果计时器开启则为真
local M = component.create("timer")


---计时器组件构造函数
---初始化计时器组件，设置文本节点、开始时间和结束时间
---@param node node GUI文本节点
---@param seconds_from number|nil 以秒为单位的计时器开始值
---@param seconds_to number|nil 以秒为单位的计时器结束值
---@param callback function|nil 当计时器值等于seconds_to时触发的函数
function M:init(node, seconds_from, seconds_to, callback)
	self.node = self:get_node(node)
	seconds_to = math.max(seconds_to or 0, 0)

	self.on_tick = event.create()
	self.on_set_enabled = event.create()
	self.on_timer_end = event.create(callback)

	if seconds_from then
		seconds_from = math.max(seconds_from, 0)
		self:set_to(seconds_from)
		self:set_interval(seconds_from, seconds_to)

		if seconds_to - seconds_from == 0 then
			self:set_state(false)
			self.on_timer_end:trigger(self:get_context(), self)
		end
	end

	return self
end

---内部方法：更新计时器
---此函数处理计时器的更新逻辑，更新计时器值并触发相应事件
---@private
function M:update(dt)
	if not self.is_on then
		return
	end

	self.temp = self.temp + dt
	local dist = math.min(1, math.abs(self.value - self.target))

	if self.temp > dist then
		self.temp = self.temp - dist
		self.value = helper.step(self.value, self.target, 1)
		self:set_to(self.value)

		self.on_tick:trigger(self:get_context(), self.value)

		if self.value == self.target then
			self:set_state(false)
			self.on_timer_end:trigger(self:get_context(), self)
		end
	end
end

---@private
function M:on_layout_change()
	self:set_to(self.last_value)
end

---将计时器设置为特定值
---此函数将计时器设置为指定的秒数并更新显示
---@param set_to number 以秒为单位的值
---@return druid.timer self 当前计时器实例
function M:set_to(set_to)
	self.last_value = set_to
	gui.set_text(self.node, self:_second_string_min(set_to))

	return self
end

---设置计时器状态
---此函数启用或禁用计时器的运行
---@param is_on boolean|nil 计时器启用状态
---@return druid.timer self 当前计时器实例
function M:set_state(is_on)
	self.is_on = is_on
	self.on_set_enabled:trigger(self:get_context(), is_on)

	return self
end

---Set the timer interval
---@param from number Start time in seconds
---@param to number Target time in seconds
---@return druid.timer self Current timer instance
function M:set_interval(from, to)
	self.from = from
	self.value = from
	self.temp = 0
	self.target = to
	self:set_state(true)
	self:set_to(from)

	return self
end

---@private
---@param sec number Seconds to convert
---@return string The formatted time string
function M:_second_string_min(sec)
	local mins = math.floor(sec / 60)
	local seconds = math.floor(sec - mins * 60)
	return string.format("%.2d:%.2d", mins, seconds)
end

return M
