--- 容器大小调整示例：展示容器的动态大小调整和子元素拉伸功能
---@class widget.container_resize: druid.widget
local M = {}


--- 初始化函数：创建可拖拽调整的容器，包含多个可拉伸的面板和锚点
function M:init()
	-- 创建父容器，用于演示大小调整
	self.parent_container = self.druid:new_container("parent_container")
	-- 为容器创建可拖拽的角落，允许用户调整容器大小
	self.parent_container:create_draggable_corners()

	-- 添加左侧和右侧面板，设置为垂直拉伸（stretch_y）
	self.parent_container:add_container("panel_left", "stretch_y")
	self.parent_container:add_container("panel_right", "stretch_y")
	-- 添加底部面板，设置为水平拉伸（stretch_x）
	self.parent_container:add_container("panel_bot", "stretch_x")

	-- 添加内容面板，并在其中添加各个方向的锚点
	self.container_content = self.parent_container:add_container("panel_content")
	self.container_content:add_container("anchor_ne")
	self.container_content:add_container("anchor_nw")
	self.container_content:add_container("anchor_se")
	self.container_content:add_container("anchor_sw")
	self.container_content:add_container("anchor_n")
	self.container_content:add_container("anchor_s")
	self.container_content:add_container("anchor_e")
	self.container_content:add_container("anchor_w")
	self.container_content:add_container("anchor_center")
end

return M
