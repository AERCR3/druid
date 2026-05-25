local event = require("event.event")

--- 数据列表增删清空示例：展示数据列表的添加、删除和清空操作
---@class examples.data_list_add_remove_clear: druid.widget
---@field prefab node
---@field scroll druid.scroll
---@field grid druid.grid
---@field data_list druid.data_list
---@field on_item_click event
local M = {}


--- 初始化函数：创建数据列表并设置初始20条数据
function M:init()
	self.prefab = self:get_node("prefab")
	gui.set_enabled(self.prefab, false)

	self.scroll = self.druid:new_scroll("view", "content")
	self.grid = self.druid:new_grid("content", self.prefab, 1)
	-- 创建数据列表控件
	self.data_list = self.druid:new_data_list(self.scroll, self.grid, self.create_item_callback) --[[@as druid.data_list]]

	-- 生成初始数据（20条）
	local data = {}
	for index = 1, 20 do
		table.insert(data, {})
	end
	self.data_list:set_data(data)

	-- 创建项目点击事件
	self.on_item_click = event.create()
end

--- 创建项目回调：克隆预制件并创建按钮
---@param item_data table 项目数据
---@param index number 项目索引
---@return node, druid.component 返回根节点和按钮组件
function M:create_item_callback(item_data, index)
	-- 克隆预制件节点树
	local nodes = gui.clone_tree(self.prefab)

	local root = nodes[self:get_template() .. "/prefab"]
	local text = nodes[self:get_template() .. "/text"]
	gui.set_enabled(root, true)
	-- 设置文本显示为"数据项"加上索引号
	gui.set_text(text, "数据项 " .. index)

	local button = self.druid:new_button(root, self.on_button_click, index)
	return root, button
end

--- 按钮点击回调：触发项目点击事件
---@param index number 被点击的项目索引
function M:on_button_click(index)
	self.on_item_click:trigger(index)
end

--- 添加项目：在指定位置添加新数据项
---@param index number|nil 插入位置索引（nil则添加到末尾）
function M:add_item(index)
	self.data_list:add({}, index)
end

--- 移除项目：移除指定位置的数据项
---@param index number|nil 要移除的位置索引（nil则移除最后一项）
function M:remove_item(index)
	-- 打印要移除的项目索引
	print("想要移除项目", index)
	self.data_list:remove(index)
end

--- 清空数据列表
function M:clear()
	self.data_list:clear()
end

--- 示例创建回调：订阅项目点击事件，点击后移除项目并记录日志
---@param output_list output_list
function M:on_example_created(output_list)
	-- 订阅项目点击事件，点击后移除该项目并记录日志
	self.on_item_click:subscribe(function(index)
		self:remove_item(index)
		output_list:add_log_text("项目已移除: " .. index)
	end)
end

--- 属性面板控制：添加裁剪开关、滚动滑块和增删清空按钮
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

	properties_panel:add_button("ui_add_element", function()
		self:add_item()
	end)

	properties_panel:add_button("ui_remove_element", function()
		self:remove_item()
	end)

	properties_panel:add_button("ui_clear_elements", function()
		self.data_list:clear()
	end)
end

--- 获取调试信息：返回数据列表和滚动视图的状态
---@return string
function M:get_debug_info()
	local data_list = self.data_list

	local data = data_list:get_data()
	local info = ""
	info = info .. "数据长度: " .. #data .. "\n"
	info = info .. "首个可视索引: " .. data_list.top_index .. "\n"
	info = info .. "末尾可视索引: " .. data_list.last_index .. "\n"

	local s = self.scroll
	info = info .. "\n"
	info = info .. "视图大小 X: " .. gui.get(s.view_node, "size.x") .. "\n"
	info = info .. "内容大小 X: " .. gui.get(s.content_node, "size.x") .. "\n"
	info = info .. "内容位置 X: " .. math.ceil(s.position.x) .. "\n"
	info = info .. "内容范围 X: " .. s.available_pos.x .. " - " .. s.available_pos.z .. "\n"

	return info
end

return M
