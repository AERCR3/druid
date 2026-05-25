--- 滚动绑定网格（锚点定位）示例：展示滚动视图的锚点定位功能
---@class examples.scroll_bind_grid_points: druid.widget
---@field scroll druid.scroll
---@field grid druid.grid
---@field text druid.text
local M = {}

--- 初始化函数：创建滚动视图和网格，设置锚点定位点
function M:init()
	self.created_nodes = {}

	self.prefab = self:get_node("prefab")
	gui.set_enabled(self.prefab, false)

	self.scroll = self.druid:new_scroll("view", "content")
	self.grid = self.druid:new_grid("content", "prefab", 1)
	self.scroll:bind_grid(self.grid)

	for index = 1, 20 do
		self:add_element()
	end

	-- 计算每个网格项的中心位置作为锚点，并偏移半个视图高度
	local points = self.grid:get_all_pos()
	for _, point in ipairs(points) do
		point.y = point.y + self.scroll.view_size.y / 2
	end
	-- 设置滚动锚点，使滚动会自动对齐到每个网格项
	self.scroll:set_points(points)
end

--- 组件移除回调：清空所有网格元素
function M:on_remove()
	self:clear()
end

--- 添加元素：克隆预制件并添加到网格中
function M:add_element()
	-- 克隆预制件并添加到网格中
	local prefab_nodes = gui.clone_tree(self.prefab)
	local root = prefab_nodes[self:get_template() .. "/prefab"]
	local text = prefab_nodes[self:get_template() .. "/text"]
	table.insert(self.created_nodes, root)
	-- 设置文本为"网格项"加上当前节点数量
	gui.set_text(text, "网格项 " .. #self.created_nodes)
	gui.set_enabled(root, true)

	self.grid:add(root)
end

--- 移除元素：删除最后一个网格元素
function M:remove_element()
	local last_node = table.remove(self.created_nodes)
	if last_node == nil then
		return
	end

	gui.delete_node(last_node)
	local grid_index = self.grid:get_index_by_node(last_node)
	self.grid:remove(grid_index)
end

--- 清空所有元素：删除所有节点并清空网格
function M:clear()
	for _, node in ipairs(self.created_nodes) do
		gui.delete_node(node)
	end
	self.created_nodes = {}
	self.grid:clear()
end

--- 属性面板控制：添加裁剪开关和增删元素按钮
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	local view_node = self.scroll.view_node
	local is_stencil = gui.get_clipping_mode(view_node) == gui.CLIPPING_MODE_STENCIL
	properties_panel:add_checkbox("ui_clipping", is_stencil, function(value)
		gui.set_clipping_mode(view_node, value and gui.CLIPPING_MODE_STENCIL or gui.CLIPPING_MODE_NONE)
	end)

	properties_panel:add_button("ui_add_element", function()
		if #self.created_nodes >= 100 then
			return
		end
		self:add_element()
	end)

	properties_panel:add_button("ui_remove_element", function()
		self:remove_element()
	end)

	properties_panel:add_button("ui_clear_elements", function()
		self:clear()
	end)
end

--- 获取调试信息：返回滚动视图和网格的状态信息
---@return string
function M:get_debug_info()
	local info = ""

	local s = self.scroll
	local view_node_size = gui.get(s.view_node, "size.y")
	local scroll_position = -s.position
	local scroll_bottom_position = vmath.vector3(scroll_position.x, scroll_position.y - view_node_size, scroll_position.z)

	-- 构建滚动视图和网格的调试信息
	info = info .. "视图大小 Y: " .. gui.get(s.view_node, "size.y") .. "\n"
	info = info .. "内容大小 Y: " .. gui.get(s.content_node, "size.y") .. "\n"
	info = info .. "内容位置 Y: " .. math.ceil(s.position.y) .. "\n"
	info = info .. "内容范围 Y: " .. s.available_pos.y .. " - " .. s.available_pos.w .. "\n"
	info = info .. "网格项数量: " .. #self.grid.nodes .. "\n"
	info = info .. "网格项大小: " .. self.grid.node_size.x .. " x " .. self.grid.node_size.y .. "\n"
	info = info .. "顶部滚动位置网格索引: " .. self.grid:get_index(scroll_position) .. "\n"
	info = info .. "底部滚动位置网格索引: " .. self.grid:get_index(scroll_bottom_position) .. "\n"

	return info
end

return M
