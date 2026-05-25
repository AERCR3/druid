---@class examples.hover: druid.widget
---@field hover druid.hover
---@field hover_pressed druid.hover
local M = {}

--- 颜色：#E6DF9F
local HOVERED_COLOR = vmath.vector4(230/255, 223/255, 159/255, 1.0)

function M:init()
	-- 默认 hover 回调是 `on_hover`，主要面向移动端
	-- 只有触摸点位于节点上方时才会触发 hover
	self.hover_default = self.druid:new_hover("button_mobile_hover/root", self.on_hover)

	-- 如果想使用鼠标悬停，可以使用 `on_mouse_hover` 回调
	-- 通过 `action_id == nil` 来区分鼠标事件
	self.hover = self.druid:new_hover("button_mouse_hover/root", nil, self.on_hover)

	self.default_color = gui.get_color(self.hover.node)
end


function M:on_hover(is_hover, hover_instance)
	gui.animate(hover_instance.node, "color", is_hover and HOVERED_COLOR or self.default_color, gui.EASING_LINEAR, 0.2)
end


return M
