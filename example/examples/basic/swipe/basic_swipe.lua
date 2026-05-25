--- 滑动手势示例：展示滑动手势的检测和方向响应
---@class examples.basic_swipe: druid.widget
---@field swipe druid.swipe
local M = {}


--- 初始化函数：创建滑动手势控件和提示文本
function M:init()
	self.swipe = self.druid:new_swipe("root", self.on_swipe) --[[@as druid.swipe]]

	self.text_hint = self:get_node("swipe_hint")
end

--- 滑动回调：根据滑动方向移动提示文本
---@param swipe_side string 滑动方向（up/down/left/right）
---@param dist number 滑动距离
---@param delta_time number 滑动时间
function M:on_swipe(swipe_side, dist, delta_time)
	-- 打印滑动信息：方向、距离和时间
	print("滑动方向:", swipe_side, "距离:", dist, "时间:", delta_time)

	-- 根据滑动方向移动提示文本
	if swipe_side == "up" then
		gui.animate(self.text_hint, gui.PROP_POSITION, vmath.vector3(0, 200, 0), gui.EASING_OUTBACK, 0.4)
	elseif swipe_side == "down" then
		gui.animate(self.text_hint, gui.PROP_POSITION, vmath.vector3(0, -200, 0), gui.EASING_OUTBACK, 0.4)
	elseif swipe_side == "left" then
		gui.animate(self.text_hint, gui.PROP_POSITION, vmath.vector3(-200, 0, 0), gui.EASING_OUTBACK, 0.4)
	elseif swipe_side == "right" then
		gui.animate(self.text_hint, gui.PROP_POSITION, vmath.vector3(200, 0, 0), gui.EASING_OUTBACK, 0.4)
	end
end

--- 示例创建回调：订阅滑动手势事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅滑动手势事件，记录滑动方向
	self.swipe.on_swipe:subscribe(function(_, side, dist, delta_time)
		output_log:add_log_text("滑动方向: " .. side)
	end)
end

return M
