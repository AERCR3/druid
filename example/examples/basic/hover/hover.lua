--- 悬停示例：展示移动端和鼠标悬停的不同处理方式
---@class examples.hover: druid.widget
---@field hover druid.hover
---@field hover_pressed druid.hover
local M = {}

--- 悬停时的高亮颜色：#E6DF9F
local HOVERED_COLOR = vmath.vector4(230 / 255, 223 / 255, 159 / 255, 1.0)

--- 初始化函数：创建移动端悬停和鼠标悬停控件
function M:init()
	-- 默认 hover 回调是 `on_hover`，主要面向移动端
	-- 只有触摸点位于节点上方时才会触发 hover
	self.hover_default = self.druid:new_hover("button_mobile_hover/root", self.on_hover)

	-- 如果想使用鼠标悬停，可以使用 `on_mouse_hover` 回调
	-- 通过 `action_id == nil` 来区分鼠标事件
	self.hover = self.druid:new_hover("button_mouse_hover/root", nil, self.on_hover)

	-- 保存默认颜色，用于鼠标离开时恢复
	self.default_color = gui.get_color(self.hover.node)
end

--- 悬停状态回调：根据悬停状态切换节点颜色
---@param is_hover boolean 是否悬停
---@param hover_instance druid.hover 悬停控件实例
function M:on_hover(is_hover, hover_instance)
	gui.animate(hover_instance.node, "color", is_hover and HOVERED_COLOR or self.default_color, gui.EASING_LINEAR, 0.2)
end

return M
