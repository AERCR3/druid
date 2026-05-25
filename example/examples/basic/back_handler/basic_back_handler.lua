--- 返回处理示例：展示back_handler处理返回键/手势的功能
---@class examples.basic_back_handler: druid.widget
local M = {}


--- 初始化函数：创建返回处理器
function M:init()
	self.druid:new_back_handler(self.on_back)
end

--- 返回回调：播放文本缩放动画
function M:on_back()
	local node = self:get_node("text")
	gui.animate(node, gui.PROP_SCALE, vmath.vector3(1.2), gui.EASING_OUTELASTIC, 0.5, 0, function()
		gui.animate(node, gui.PROP_SCALE, vmath.vector3(1), gui.EASING_OUTELASTIC, 0.5)
	end)
end

return M
