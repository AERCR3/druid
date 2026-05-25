local const = require("druid.const")
local event = require("event.event")
local helper = require("druid.helper")
local component = require("druid.component")

---@class druid.grid.style
---@field IS_DYNAMIC_NODE_POSES boolean|nil 如果为真，则始终将网格内容居中为网格枢轴设置。默认值: false
---@field IS_ALIGN_LAST_ROW boolean|nil 如果为真，则始终将网格的最后一行对齐为网格枢轴设置。默认值: false

---用于管理网格中节点位置的组件，带有各种选项
---静态网格组件用于在规则网格布局中排列UI元素，支持多种对齐选项
---@class druid.grid: druid.component
---@field on_add_item event fun(self: druid.grid, item: node, index: number) Trigger on add item event
---@field on_remove_item event fun(self: druid.grid, index: number) Trigger on remove item event
---@field on_change_items event fun(self: druid.grid, index: number) Trigger on change items event
---@field on_clear event fun(self: druid.grid) Trigger on clear event
---@field on_update_positions event fun(self: druid.grid) Trigger on update positions event
---@field parent node Parent node
---@field nodes node[] Nodes array
---@field first_index number First index
---@field last_index number Last index
---@field anchor vector3 Anchor
---@field pivot vector3 Pivot
---@field node_size vector3 Node size
---@field border vector4 Border
---@field in_row number In row
---@field style druid.grid.style Style
local M = component.create("grid")


---网格组件的构造函数
---初始化网格组件，设置网格容器、元素预制件和每行节点数
---@param parent string|node GUI节点容器，网格项目将放置在此处
---@param element node 元素预制件。需要获取其大小
---@param in_row number|nil 每行可以放置多少个节点。默认为1
function M:init(parent, element, in_row)
	self.parent = self:get_node(parent)
	self.nodes = {}

	self.pivot = helper.get_pivot_offset(self.parent)
	self.anchor = vmath.vector3(0.5 + self.pivot.x, 0.5 - self.pivot.y, 0)

	self.in_row = in_row or 1

	self._prefab = self:get_node(element)
	self.node_size = gui.get_size(self._prefab)
	self.node_pivot = const.PIVOTS[gui.get_pivot(self._prefab)]

	self._grid_horizonal_offset = self.node_size.x * (self.in_row - 1) * self.anchor.x
	self._zero_offset = vmath.vector3(
		self.node_size.x * self.node_pivot.x - self.node_size.x * self.pivot.x - self._grid_horizonal_offset,
		self.node_size.y * self.node_pivot.y - self.node_size.y * self.pivot.y,
		0)

	self.border = vmath.vector4(0) -- Current grid content size

	self.on_add_item = event.create()
	self.on_remove_item = event.create()
	self.on_change_items = event.create()
	self.on_clear = event.create()
	self.on_update_positions = event.create()

	self._set_position_function = gui.set_position
end

---内部方法：处理样式变化
---当网格组件样式发生变化时调用此私有方法
---@private
---@param style druid.grid.style 网格样式
function M:on_style_change(style)
	self.style = {
		IS_DYNAMIC_NODE_POSES = style.IS_DYNAMIC_NODE_POSES or false,
		IS_ALIGN_LAST_ROW = style.IS_ALIGN_LAST_ROW or false,
	}
end

local _temp_pos = vmath.vector3(0)
---根据网格节点索引返回位置
---此函数计算指定索引的网格元素在网格中的位置坐标
---@param index number 网格元素索引
---@return vector3 position 节点位置
function M:get_pos(index)
	local row = math.ceil(index / self.in_row) - 1
	local col = (index - row * self.in_row) - 1

	local zero_offset_x = self:_get_zero_offset_x(row)

	_temp_pos.x = col * self.node_size.x + zero_offset_x
	_temp_pos.y = -row * self.node_size.y + self._zero_offset.y
	_temp_pos.z = 0

	return _temp_pos
end

---根据位置返回网格索引
---此函数根据给定的位置坐标计算出对应的网格元素索引
---@param pos vector3 网格中的节点位置
---@return number index 节点索引
function M:get_index(pos)
	-- Offset to left-top corner from node pivot
	local node_offset_x = self.node_size.x * (-0.5 + self.node_pivot.x)
	local node_offset_y = self.node_size.y * (0.5 - self.node_pivot.y)

	local col = (pos.x + node_offset_x) / self.node_size.x + 1
	local row = -(pos.y + node_offset_y) / self.node_size.y

	col = helper.round(col)
	row = helper.round(row)

	local index = col + (row * self.in_row)
	return math.ceil(index)
end

---根据节点返回网格索引
---@param node node 网格中的GUI节点
---@return number|nil index 节点索引
function M:get_index_by_node(node)
	for index, grid_node in pairs(self.nodes) do
		if node == grid_node then
			return index
		end
	end

	return nil
end

---@private
function M:on_layout_change()
	self:_update(true)
end

---设置网格锚点。默认锚点等于网格父节点的锚点
---@param anchor vector3 锚点
function M:set_anchor(anchor)
	self.anchor = anchor
	self:_update()
end

---立即更新网格内容
---@return druid.grid self 当前网格实例
function M:refresh()
	self:_update(true)

	return self
end

---设置网格枢轴点
---@param pivot constant 新的枢轴点
---@return druid.grid self 当前网格实例
function M:set_pivot(pivot)
	local prev_pivot = helper.get_pivot_offset(gui.get_pivot(self.parent))
	self.pivot = helper.get_pivot_offset(pivot)

	local width = gui.get(self.parent, "size.x")
	local height = gui.get(self.parent, "size.y")

	local position = gui.get_position(self.parent)
	position.x = position.x + width * (self.pivot.x - prev_pivot.x)
	position.y = position.y + height * (self.pivot.y - prev_pivot.y)
	gui.set_position(self.parent, position)

	gui.set_pivot(self.parent, pivot)

	self.anchor = vmath.vector3(0.5 + self.pivot.x, 0.5 - self.pivot.y, 0)
	self._grid_horizonal_offset = self.node_size.x * (self.in_row - 1) * self.anchor.x
	self._zero_offset = vmath.vector3(
		self.node_size.x * self.node_pivot.x - self.node_size.x * self.pivot.x - self._grid_horizonal_offset,
		self.node_size.y * self.node_pivot.y - self.node_size.y * self.pivot.y,
		0
	)

	self:_update(true)

	return self
end

---向网格添加新项目
---@param item node GUI节点
---@param index number|nil 项目位置。默认添加为最后一个项目
---@param shift_policy number|nil 如何移动节点（如果需要）。默认：const.SHIFT.RIGHT
---@param is_instant boolean|nil 如果为true，立即更新节点位置
---@return druid.grid self 当前网格实例
function M:add(item, index, shift_policy, is_instant)
	index = index or ((self.last_index or 0) + 1)

	helper.insert_with_shift(self.nodes, item, index, shift_policy)
	gui.set_parent(item, self.parent)

	-- Add new item instantly in new pos. Break update function for correct positioning
	self:_update_indexes()
	self:_update_borders()

	gui.set_position(item, self:get_pos(index) + self:_get_zero_offset())

	self:_update_pos(is_instant)

	self.on_add_item:trigger(self:get_context(), item, index)
	self.on_change_items:trigger(self:get_context(), index)

	return self
end

---设置网格的新项目。所有之前的项目将被移除
---@param nodes node[] 新的网格节点
---@param is_instant boolean|nil 如果为true，立即更新节点位置
---@return druid.grid self 当前网格实例
function M:set_items(nodes, is_instant)
	self.nodes = nodes
	for index = 1, #nodes do
		local item = nodes[index]
		gui.set_parent(item, self.parent)
	end

	self:_update(is_instant)

	self.on_change_items:trigger(self:get_context())

	return self
end

---从网格中移除项目。请注意GUI节点不会被删除
---@param index number 要移除的网格节点索引
---@param shift_policy number|nil 如何移动节点（如果需要）。默认：const.SHIFT.RIGHT
---@param is_instant boolean|nil 如果为true，立即更新节点位置
---@return node node 从网格中删除的GUI节点
function M:remove(index, shift_policy, is_instant)
	assert(self.nodes[index], "No grid item at given index " .. index)

	local remove_node = self.nodes[index]
	helper.remove_with_shift(self.nodes, index, shift_policy)

	self:_update(is_instant)

	self.on_remove_item:trigger(self:get_context(), index)
	self.on_change_items:trigger(self:get_context(), index)

	return remove_node
end

---返回网格中的项目数量
---@return number count 网格中的项目数量
function M:get_items_count()
	return #self.nodes
end

---返回网格内容大小
---@return vector3 size 网格内容大小
function M:get_size()
	return vmath.vector3(
		self.border.z - self.border.x,
		self.border.y - self.border.w,
		0)
end

---返回指定节点数量的网格内容大小
---@param count number 节点数量
---@return vector3 size 网格内容大小
function M:get_size_for(count)
	if not count or count == 0 then
		return vmath.vector3(0)
	end

	local border = vmath.vector4(math.huge, -math.huge, -math.huge, math.huge)

	local size = self.node_size
	local pivot = self.node_pivot
	self:_extend_border(border, self:get_pos(1), size, pivot)
	self:_extend_border(border, self:get_pos(count), size, pivot)
	if count >= self.in_row then
		self:_extend_border(border, self:get_pos(self.in_row), size, pivot)
	end

	return vmath.vector3(
		border.z - border.x,
		border.y - border.w,
		0)
end

---返回网格内容边框
---@return vector4 borders 网格内容边框
function M:get_borders()
	return self.border
end

---返回所有节点位置的数组
---@return vector3[] positions 所有网格节点位置
function M:get_all_pos()
	local result = {}
	for i, node in pairs(self.nodes) do
		table.insert(result, gui.get_position(node))
	end

	return result
end

---更改网格节点的位置设置函数。它将在
-- 更新网格元素位置时被调用。默认：gui.set_position
---@param callback function 节点位置设置函数
---@return druid.grid self 当前网格实例
function M:set_position_function(callback)
	self._set_position_function = callback or gui.set_position

	return self
end

---清除网格节点数组。GUI节点不会被删除！
-- 如果您想删除GUI节点，请在grid:clear之前使用static_grid.nodes数组
---@return druid.grid self 当前网格实例
function M:clear()
	self.border.x = 0
	self.border.y = 0
	self.border.w = 0
	self.border.z = 0

	self.nodes = {}
	self:_update()

	self.on_clear:trigger(self:get_context())
	self.on_change_items:trigger(self:get_context())

	return self
end

---返回StaticGrid的偏移量，StaticGrid内容从此开始
---@return vector3 offset StaticGrid的偏移量
function M:get_offset()
	local borders = self:get_borders()
	local size = self:get_size()

	local offset = vmath.vector3(
		(borders.z + borders.x) / 2 + size.x * self.pivot.x,
		(borders.y + borders.w) / 2 + size.y * self.pivot.y,
		0)

	return offset
end

---为网格设置新的每行元素数量
---@param in_row number 新的in_row值
---@return druid.grid self 当前网格实例
function M:set_in_row(in_row)
	self.in_row = in_row
	self._grid_horizonal_offset = self.node_size.x * (self.in_row - 1) * self.anchor.x
	self._zero_offset = vmath.vector3(
		self.node_size.x * self.node_pivot.x - self.node_size.x * self.pivot.x - self._grid_horizonal_offset,
		self.node_size.y * self.node_pivot.y - self.node_size.y * self.pivot.y,
		0)

	self:_update(true)
	self.on_change_items:trigger(self:get_context())

	return self
end

---为网格设置新的节点大小
---@param width number|nil 新的节点宽度
---@param height number|nil 新的节点高度
---@return druid.grid self 当前网格实例
function M:set_item_size(width, height)
	if width then
		self.node_size.x = width
	end
	if height then
		self.node_size.y = height
	end
	self._grid_horizonal_offset = self.node_size.x * (self.in_row - 1) * self.anchor.x
	self._zero_offset = vmath.vector3(
		self.node_size.x * self.node_pivot.x - self.node_size.x * self.pivot.x - self._grid_horizonal_offset,
		self.node_size.y * self.node_pivot.y - self.node_size.y * self.pivot.y,
		0)

	self:_update()
	self.on_change_items:trigger(self:get_context())

	return self
end

---通过自定义比较函数对网格节点进行排序
---@param comparator function 比较函数。(a, b) -> boolean
---@return druid.grid self 当前网格实例
function M:sort_nodes(comparator)
	table.sort(self.nodes, comparator)
	self:_update(true)

	return self
end

---更新网格内部状态
---@param is_instant boolean|nil 如果为true，节点位置立即更新，否则使用set_position_function回调
---@private
function M:_update(is_instant)
	self:_update_indexes()
	self:_update_borders()
	self:_update_pos(is_instant)
end

---更新网格节点的第一个和最后一个索引
---@private
function M:_update_indexes()
	self.first_index = nil
	self.last_index = nil
	for index in pairs(self.nodes) do
		self.first_index = self.first_index or index
		self.last_index = self.last_index or index

		self.first_index = math.min(self.first_index, index)
		self.last_index = math.max(self.last_index, index)
	end
end

---更新网格内容边框，重新计算最小和最大值
---@private
function M:_update_borders()
	if not self.first_index then
		self.border = vmath.vector4(0)
		return
	end

	self.border = vmath.vector4(math.huge, -math.huge, -math.huge, math.huge)

	local size = self.node_size
	local pivot = self.node_pivot
	for index, node in pairs(self.nodes) do
		self:_extend_border(self.border, self:get_pos(index), size, pivot)
	end
end

---更新网格节点位置
---@param is_instant boolean|nil 如果为true，节点位置立即更新，否则使用set_position_function回调
---@private
function M:_update_pos(is_instant)
	local zero_offset = self:_get_zero_offset()

	for i, node in pairs(self.nodes) do
		local pos = self:get_pos(i)
		pos.x = pos.x + zero_offset.x
		pos.y = pos.y + zero_offset.y

		if is_instant then
			gui.set_position(node, pos)
		else
			self._set_position_function(node, pos)
		end
	end

	self.on_update_positions:trigger(self:get_context())
end

---返回正确设置节点位置时的元素偏移量。在父枢轴节点(0:0)
---处正确设置位置，调整节点大小和锚点
---@return vector3 偏移向量
---@private
function M:_get_zero_offset()
	if not self.style.IS_DYNAMIC_NODE_POSES then
		return vmath.vector3(0)
	end

	-- zero offset: center pos - border size * anchor
	return vmath.vector3(
		-((self.border.x + self.border.z) / 2 + (self.border.z - self.border.x) * self.pivot.x),
		-((self.border.y + self.border.w) / 2 + (self.border.y - self.border.w) * self.pivot.y),
		0
	)
end

---返回网格最后一行的X偏移量。用于根据网格的锚点对齐该行
---@return number X偏移量值
---@private
function M:_get_zero_offset_x(row_index)
	if not self.style.IS_DYNAMIC_NODE_POSES or not self.style.IS_ALIGN_LAST_ROW then
		return self._zero_offset.x
	end

	local offset_x = self._zero_offset.x
	local last_row = math.ceil(self.last_index / self.in_row) - 1

	if last_row > 0 and last_row == row_index then
		local elements_in_row = (self.last_index - (last_row * self.in_row)) - 1
		local offset = elements_in_row * self.node_size.x * self.anchor.x
		offset_x = self.node_size.x * self.node_pivot.x - self.node_size.x * self.pivot.x - offset
	end

	return offset_x
end

---@param border vector4 将使用新的边框值更新
---@param pos vector3 位置
---@param size vector3 大小
---@param pivot vector3 枢轴
function M:_extend_border(border, pos, size, pivot)
	local left = pos.x - size.x / 2 - (size.x * pivot.x)
	local right = pos.x + size.x / 2 - (size.x * pivot.x)
	local top = pos.y + size.y / 2 - (size.y * pivot.y)
	local bottom = pos.y - size.y / 2 - (size.y * pivot.y)

	border.x = math.min(border.x, left)
	border.y = math.max(border.y, top)
	border.z = math.max(border.z, right)
	border.w = math.min(border.w, bottom)
end

return M
