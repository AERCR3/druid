local const = require("druid.const")
local helper = require("druid.helper")
local component = require("druid.component")
local event = require("event.event")

---Druid组件，用于管理带有可滚动视图的数据列表，用于管理大量列表数据并仅渲染可见元素。
---
---### 设置
---使用druid创建数据列表组件: `data_list = druid:new_data_list(scroll, grid, create_function)`
---
---### 注意事项
---- 数据列表使用滚动组件进行滚动，使用网格组件进行布局
---- 数据列表仅渲染可见元素以获得更好的性能
---- 数据列表支持缓存元素以获得更好的性能
---- 数据列表支持添加、删除和更新元素
---- 数据列表支持滚动到特定元素
---- 数据列表支持自定义元素创建和清理
---DataList组件是处理大量数据展示的高性能组件，采用虚拟滚动技术优化性能
---@class druid.data_list: druid.component
---@field scroll druid.scroll The scroll instance for Data List component
---@field grid druid.grid The StaticGrid or DynamicGrid instance for Data List component
---@field on_scroll_progress_change event fun(self: druid.data_list, progress: number) The event triggered when the scroll progress changes
---@field on_element_add event fun(self: druid.data_list, index: number, node: node, instance: druid.component, data: table) The event triggered when a new element is added
---@field on_element_remove event fun(self: druid.data_list, index: number, node: node, instance: druid.component, data: table) The event triggered when an element is removed
---@field top_index number The top index of the visible elements
---@field last_index number The last index of the visible elements
---@field scroll_progress number The scroll progress
---@field private _create_function function The create function callback(self, data, index, data_list). Function should return (node, [component])
---@field private _is_use_cache boolean Use cache version of DataList. Requires make setup of components in on_element_add callback and clean in on_element_remove
---@field private _cache table The cache table
---@field private _data table The data table
---@field private _data_visual table The data visual table
local M = component.create("data_list")


---DataList构造函数
---初始化DataList组件，设置滚动实例、网格实例和创建函数
---@param scroll druid.scroll 数据列表组件的滚动实例
---@param grid druid.grid 数据列表组件的静态网格实例
---@param create_function function 创建函数回调(self, data, index, data_list)。函数应返回(node, [component])
function M:init(scroll, grid, create_function)
	self.scroll = scroll
	self.grid = grid
	if self.grid.style then
		self.grid.style.IS_DYNAMIC_NODE_POSES = false
	end

	-- Current visual elements indexes
	self.top_index = 1
	self.last_index = 1
	self.scroll_progress = 0

	self._create_function = create_function
	self._is_use_cache = false
	self._cache = {}
	self._data = {}
	self._data_visual = {}

	self.scroll.on_scroll:subscribe(self._refresh, self)

	self.on_scroll_progress_change = event.create()
	self.on_element_add = event.create()
	self.on_element_remove = event.create()
end

---@private
function M:on_remove()
	self:clear()
	self.scroll.on_scroll:unsubscribe(self._refresh, self)
end

---设置使用DataList的缓存版本。需要在on_element_add回调中设置组件并在on_element_remove中清理
---启用缓存可以显著提高性能，特别是在频繁添加/删除元素的情况下
---@param is_use_cache boolean 使用DataList的缓存版本
---@return druid.data_list self 当前DataList实例
function M:set_use_cache(is_use_cache)
	self._is_use_cache = is_use_cache
	return self
end

---为DataList组件设置新数据集
---此函数替换现有数据并刷新显示，适用于数据完全更新的情况
---@param data table 新的数据数组
---@return druid.data_list self 当前DataList实例
function M:set_data(data)
	self._data = data or {}
	self:_refresh()

	return self
end

---Return current data from DataList component
---@return table data The current data array
function M:get_data()
	return self._data
end

---Add element to DataList
---@param data table The data to add
---@param index number|nil The index to add the data at
---@param shift_policy number|nil The constant from const.SHIFT.*
---@return druid.data_list self Current DataList instance
function M:add(data, index, shift_policy)
	index = index or #self._data + 1
	shift_policy = shift_policy or const.SHIFT.RIGHT

	helper.insert_with_shift(self._data, data, index, shift_policy)
	self:_refresh()

	return self
end

---Remove element from DataList
---@param index number|nil The index to remove the data at
---@param shift_policy number|nil The constant from const.SHIFT.*
---@return druid.data_list self Current DataList instance
function M:remove(index, shift_policy)
	helper.remove_with_shift(self._data, index, shift_policy)
	self:_refresh()

	return self
end

---Remove element from DataList by data value
---@param data table The data to remove
---@param shift_policy number|nil The constant from const.SHIFT.*
---@return druid.data_list self Current DataList instance
function M:remove_by_data(data, shift_policy)
	local index = helper.contains(self._data, data)
	if index then
		helper.remove_with_shift(self._data, index, shift_policy)
		self:_refresh()
	end

	return self
end

---Clear the DataList and refresh visuals
---@return druid.data_list self Current DataList instance
function M:clear()
	self._data = {}
	self:_refresh()

	return self
end

---Return index for data value
---@param data table
function M:get_index(data)
	for index, value in pairs(self._data) do
		if value == data then
			return index
		end
	end

	return nil
end

---Return all currently created nodes in DataList
---@return node[] List of created nodes
function M:get_created_nodes()
	local nodes = {}

	for index, data in pairs(self._data_visual) do
		nodes[index] = data.node
	end

	return nodes
end

---Return all currently created components in DataList
---@return druid.component[] components List of created components
function M:get_created_components()
	local components = {}

	for index, data in pairs(self._data_visual) do
		components[index] = data.component
	end

	return components
end

---Instant scroll to element with passed index
---@param index number The index to scroll to
function M:scroll_to_index(index)
	local pos = self.grid:get_pos(index)
	self.scroll:scroll_to(pos)
end

---Add element at passed index using cache or create new
---@param index number The index to add the element at
---@private
function M:_add_at(index)
	if self._data_visual[index] then
		self:_remove_at(index)
	end

	local data = self._data[index]
	local node, instance

	-- Use cache if available and is_use_cache is set
	if #self._cache > 0 and self._is_use_cache then
		local cached = table.remove(self._cache)
		node = cached.node
		instance = cached.component
		gui.set_enabled(node, true)
	else
		-- Create a new element if no cache or refresh function is not set
		node, instance = self._create_function(self:get_context(), data, index, self)
	end

	self._data_visual[index] = {
		data = data,
		node = node,
		component = instance,
	}
	self.grid:add(node, index, const.SHIFT.NO_SHIFT)

	self.on_element_add:trigger(self:get_context(), index, node, instance, data)
end

---Remove element from passed index and add it to cache if applicable
---@param index number The index to remove the element at
---@private
function M:_remove_at(index)
	self.grid:remove(index, const.SHIFT.NO_SHIFT)

	local visual_data = self._data_visual[index]
	local node = visual_data.node
	local instance = visual_data.component
	local data = visual_data.data

	self.on_element_remove:trigger(self:get_context(), index, node, instance, data)

	if self._is_use_cache then
		-- Disable the node and add it to the cache instead of deleting it
		gui.set_enabled(node, false)
		table.insert(self._cache, visual_data) -- Cache the removed element
	else
		-- If no refresh function, delete the node and component as usual
		gui.delete_node(node)
		if instance then
			instance._meta.druid:remove(instance)
		end
	end

	self._data_visual[index] = nil
end

---Refresh all elements in DataList
---@private
function M:_refresh()
	self.scroll:set_size(self.grid:get_size_for(#self._data))

	local start_pos = -self.scroll.position --[[@as vector3]]
	local start_index = self.grid:get_index(start_pos)
	start_index = math.max(1, start_index)

	local offset_x = self.scroll.view_size.x
	local offset_y = self.scroll.view_size.y
	local end_pos = vmath.vector3(start_pos.x + offset_x, start_pos.y - offset_y, 0)

	local max_offset_x = (self.grid.in_row - 1) * self.grid.node_size.x
	end_pos.x = math.min(end_pos.x, start_pos.x + max_offset_x)

	if #self._data <= self.grid.in_row then
		end_pos.y = start_pos.y
	end

	local end_index = self.grid:get_index(end_pos)
	end_index = math.min(#self._data, end_index)

	self.top_index = start_index
	self.last_index = end_index

	-- Clear from non range elements
	for index, data in pairs(self._data_visual) do
		if index < start_index or index > end_index then
			self:_remove_at(index)
		elseif self._data[index] ~= data.data then
			-- TODO We want to find currently created data instances and move them to new positions
			-- Now it will re-create them
			self:_remove_at(index)
		end
	end

	-- Add new elements
	for index = start_index, end_index do
		if not self._data_visual[index] and self._data[index] then
			self:_add_at(index)
		end
	end
end

return M
