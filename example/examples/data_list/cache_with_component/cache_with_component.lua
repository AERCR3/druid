local event = require("event.event")

local button_component = require("example.examples.data_list.cache_with_component.button_component")

--- 带组件缓存的数据列表示例：展示使用组件缓存机制的数据列表
---@class examples.data_list_cache_with_component: druid.widget
---@field prefab node
---@field scroll druid.scroll
---@field grid druid.grid
---@field data_list druid.data_list
---@field on_item_click event
local M = {}


--- 初始化函数：创建数据列表，启用组件缓存并设置初始1000条数据
function M:init()
	self.prefab = self:get_node("button_component/root")
	gui.set_enabled(self.prefab, false)

	self.scroll = self.druid:new_scroll("view", "content")
	self.grid = self.druid:new_grid("content", self.prefab, 1)
	self.data_list = self.druid:new_data_list(self.scroll, self.grid, self.create_item_callback) --[[@as druid.data_list]]
	-- 启用组件缓存：滚动时复用已创建的组件，而非每次重新创建
	self.data_list:set_use_cache(true)
	-- 订阅元素添加和移除事件，用于初始化/清理组件状态
	self.data_list.on_element_add:subscribe(self.on_element_add)
	self.data_list.on_element_remove:subscribe(self.on_element_remove)

	-- 生成初始数据（1000条）
	local data = {}
	for index = 1, 1000 do
		table.insert(data, {})
	end
	self.data_list:set_data(data)

	-- 创建项目点击事件
	self.on_item_click = event.create()
end

--- 创建项目回调：使用按钮组件创建列表项
---@param item_data table 项目数据
---@param index number 项目索引
---@return node, druid.component 返回根节点和按钮组件实例
function M:create_item_callback(item_data, index)
	local instance = self.druid:new_widget(button_component, "button_component", self.prefab)
	gui.set_enabled(instance.root, true)

	return instance.root, instance
end

--- 元素添加回调：初始化按钮组件的文本和数据
---@param index number 项目索引
---@param node node 根节点
---@param instance examples.button_component 按钮组件实例
---@param data table 项目数据
function M:on_element_add(index, node, instance, data)
	-- 设置按钮文本为"数据项"加上索引号
	instance.text:set_text("数据项 " .. index)
	instance.button.on_click:subscribe(self.on_button_click, self)
	instance:set_data(index)
end

--- 元素移除回调：取消订阅按钮点击事件
---@param index number 项目索引
---@param node node 根节点
---@param instance examples.button_component 按钮组件实例
---@param data table 项目数据
function M:on_element_remove(index, node, instance, data)
	instance.button.on_click:unsubscribe(self.on_button_click, self)
end

--- 按钮点击回调：获取关联数据并触发项目点击事件
---@param instance examples.button_component 按钮组件实例
function M:on_button_click(instance)
	local data = instance:get_data()
	self.on_item_click:trigger(data)
end

--- 示例创建回调：订阅项目点击事件并记录日志
---@param output_list output_list
function M:on_example_created(output_list)
	-- 订阅项目点击事件并记录日志
	self.on_item_click:subscribe(function(index)
		output_list:add_log_text("项目已点击: " .. index)
	end)
end

--- 属性面板控制：添加裁剪开关和滚动滑块
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	local view_node = self.scroll.view_node
	local is_stencil = gui.get_clipping_mode(view_node) == gui.CLIPPING_MODE_STENCIL

	properties_panel:add_checkbox("ui_clipping", is_stencil, function(value)
		gui.set_clipping_mode(view_node, value and gui.CLIPPING_MODE_STENCIL or gui.CLIPPING_MODE_NONE)
	end)

	properties_panel:add_slider("ui_scroll", 0, function(value)
		self.scroll:scroll_to_percent(vmath.vector3(0, 1 - value, 0), true)
	end)
end

--- 获取调试信息：返回数据列表和滚动视图的状态
---@return string
function M:get_debug_info()
	local data_list = self.data_list

	local data = data_list:get_data()
	local info = ""
	-- 构建调试信息字符串
	info = info .. "数据长度: " .. #data .. "\n"
	info = info .. "首个可视索引: " .. data_list.top_index .. "\n"
	info = info .. "末尾可视索引: " .. data_list.last_index .. "\n"

	local s = self.scroll
	info = info .. "\n"
	info = info .. "视图大小 Y: " .. gui.get(s.view_node, "size.y") .. "\n"
	info = info .. "内容大小 Y: " .. gui.get(s.content_node, "size.y") .. "\n"
	info = info .. "内容位置 Y: " .. math.ceil(s.position.y) .. "\n"
	info = info .. "内容范围 Y: " .. s.available_pos.y .. " - " .. s.available_pos.w .. "\n"

	return info
end

return M
