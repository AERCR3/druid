--- 容器锚点示例：展示容器的各种锚点定位功能
---@class widget.container_anchors: druid.widget
local M = {}


--- 初始化函数：创建可拖拽的父容器并添加多个锚点子容器
function M:init()
	-- 创建父容器，用于演示锚点定位
	self.parent_container = self.druid:new_container("parent_container")
	-- 为容器创建可拖拽的角落，允许用户调整容器大小
	self.parent_container:create_draggable_corners()

	-- 添加各个方向的锚点容器：东北、西北、东南、西南、北、南、东、西、中心
	self.parent_container:add_container("anchor_ne")
	self.parent_container:add_container("anchor_nw")
	self.parent_container:add_container("anchor_se")
	self.parent_container:add_container("anchor_sw")
	self.parent_container:add_container("anchor_n")
	self.parent_container:add_container("anchor_s")
	self.parent_container:add_container("anchor_e")
	self.parent_container:add_container("anchor_w")
	self.parent_container:add_container("anchor_center")
end

return M
