local hover_hint = require("example.examples.widgets.hover_hint.hover_hint")

--- 悬停提示示例：展示为不同颜色的盒子添加悬停提示框
---@class examples.hover_hint_example: druid.widget
local M = {}

--- 初始化函数：创建悬停提示组件并为四个彩色盒子添加提示
function M:init()
	-- 创建悬停提示组件
	self.hover_hint = self.druid:new_widget(hover_hint, "hover_hint")

	-- 为黄色盒子添加提示，触发点在北侧，提示框在南侧
	self.hover_hint:add_hover_hint(self:get_node("node_yellow"), "Yellow box", gui.PIVOT_N, gui.PIVOT_S)
	-- 为绿色盒子添加提示，触发点在南侧，提示框在北侧
	self.hover_hint:add_hover_hint(self:get_node("node_green"), "Green box", gui.PIVOT_S, gui.PIVOT_N)
	-- 为红色盒子添加提示，触发点在东侧，提示框在西侧
	self.hover_hint:add_hover_hint(self:get_node("node_red"), "Red box", gui.PIVOT_E, gui.PIVOT_W)
	-- 为蓝色盒子添加提示，触发点在西侧，提示框在东侧
	self.hover_hint:add_hover_hint(self:get_node("node_blue"), "And this is definitely a blue box", gui.PIVOT_W,
		gui.PIVOT_E)
end

return M
