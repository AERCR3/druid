--- 拖拽示例：展示拖拽控件的使用，支持拖拽移动和回弹动画
---@class examples.drag: druid.widget
local M = {}


--- 初始化函数：创建拖拽控件，设置拖拽移动和回弹
function M:init()
	-- 初始化拖拽：在拖拽回调中移动节点
	self.drag = self.druid:new_drag("drag/root", function(_, dx, dy)
		local position_x = gui.get(self.drag.node, "position.x")
		local position_y = gui.get(self.drag.node, "position.y")
		gui.set(self.drag.node, "position.x", position_x + dx)
		gui.set(self.drag.node, "position.y", position_y + dy)
	end)

	-- 保存初始位置，用于拖拽结束时回弹动画
	self.start_position = gui.get_position(self.drag.node)
	self.drag.on_drag_end:subscribe(function()
		gui.animate(self.drag.node, "position", self.start_position, gui.EASING_OUTBACK, 0.3)
	end)
end

return M
