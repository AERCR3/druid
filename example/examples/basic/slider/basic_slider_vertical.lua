local helper = require("druid.helper")

--- 垂直滑块示例：展示垂直方向的滑块控件
---@class examples.basic_slider_vertical: druid.widget
---@field root node
---@field slider druid.slider
local M = {}

--- 初始化函数：创建垂直滑块并设置输入区域
function M:init()
	self.slider = self.druid:new_slider("slider/slider_pin", vmath.vector3(0, 118, 0), self.on_slider_change) --[[@as druid.slider]]

	-- 如需让整个 slider 区域都能响应拖动，可指定根节点作为额外的输入节点
	self.slider:set_input_node("slider/root")

	self.text_value = self:get_node("slider_value")
end

--- 滑块值改变回调：更新百分比文本
---@param value number 滑块值
function M:on_slider_change(value)
	gui.set_text(self.text_value, math.ceil(value * 100) .. "%")
end

--- 示例创建回调：订阅滑块值改变事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅滑块值改变事件，记录滑块的值
	self.slider.on_change_value:subscribe(function(_, value)
		value = helper.round(value, 2)
		output_log:add_log_text("滑块值: " .. value)
	end)
end

return M
