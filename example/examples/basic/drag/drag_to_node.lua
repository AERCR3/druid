--- 拖拽到目标节点示例：展示将元素拖拽到指定区域并触发事件
---@class examples.drag_to_node: druid.widget
local M = {}


--- 初始化函数：创建拖拽控件、按钮和目标区域
function M:init()
	self.zone = self:get_node("zone")
	self.counter = 0
	self.text_counter = self:get_node("text_counter")
	gui.set_text(self.text_counter, self.counter)

	-- 初始化拖拽：在拖拽回调中移动节点，并检测是否拖入目标区域
	self.drag = self.druid:new_drag("drag/root", self.on_drag)
	self.drag.on_drag_end:subscribe(self.on_drag_end)

	self.druid:new_button("drag/root", function()
		self.counter = self.counter - 1
		gui.set_text(self.text_counter, self.counter)
		self:on_drop_to_zone()
	end)

	-- 保存初始位置，用于拖拽结束时回弹
	self.start_position = gui.get_position(self.drag.node)
end

--- 拖拽回调：移动节点并检测是否进入目标区域
function M:on_drag(dx, dy, x, y, touch)
	local position_x = gui.get(self.drag.node, "position.x")
	local position_y = gui.get(self.drag.node, "position.y")
	gui.set(self.drag.node, "position.x", position_x + dx)
	gui.set(self.drag.node, "position.y", position_y + dy)

	local is_pick_zone = gui.pick_node(self.zone, touch.x, touch.y)
	self:on_hover_pick_zone(is_pick_zone)
end

--- 拖拽结束回调：回弹到初始位置，检测是否拖入目标区域
function M:on_drag_end(x, y, touch)
	gui.animate(self.drag.node, "position", self.start_position, gui.EASING_OUTBACK, 0.3)

	local is_pick_zone = gui.pick_node(self.zone, touch.x, touch.y)
	if is_pick_zone then
		self.counter = self.counter + 1
		gui.set_text(self.text_counter, self.counter)
		self:on_drop_to_zone()
	end
	self:on_hover_pick_zone(false)
end

--- 悬停目标区域回调：根据是否悬停在目标区域上更新透明度
function M:on_hover_pick_zone(is_pick_zone)
	local target_alpha = is_pick_zone and 1.5 or 1
	gui.animate(self.zone, "color.w", target_alpha, gui.EASING_OUTSINE, 0.3)
end

--- 拖入目标区域回调：播放缩放动画效果
function M:on_drop_to_zone()
	gui.set_scale(self.zone, vmath.vector3(1.2))
	gui.animate(self.zone, "scale", vmath.vector3(1), gui.EASING_OUTBACK, 0.3)
end

return M
