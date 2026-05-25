--- 水平数据列表示例：展示水平方向的数据列表
---@class examples.data_list_horizontal_basic: druid.widget
---@field prefab node
---@field scroll druid.scroll
---@field grid druid.grid
---@field data_list druid.data_list
local M = {}


--- 初始化函数：创建水平数据列表并设置初始100条数据
function M:init()
	self.prefab = self:get_node("prefab")
	gui.set_enabled(self.prefab, false)

	self.scroll = self.druid:new_scroll("view", "content")
	self.grid = self.druid:new_grid("content", self.prefab, 1000)
	self.data_list = self.druid:new_data_list(self.scroll, self.grid, self.create_item_callback) --[[@as druid.data_list]]

	local data = {}
	for index = 1, 100 do
		table.insert(data, {})
	end
	self.data_list:set_data(data)
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

--- 按钮点击回调：打印点击的项目索引
---@param index number 被点击的项目索引
function M:on_button_click(index)
	-- 打印按钮点击的项目索引
	print("按钮已点击", index)
end

--- 属性面板控制：添加裁剪开关
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	local view_node = self.scroll.view_node
	local is_stencil = gui.get_clipping_mode(view_node) == gui.CLIPPING_MODE_STENCIL

	properties_panel:add_checkbox("ui_clipping", is_stencil, function(value)
		gui.set_clipping_mode(view_node, value and gui.CLIPPING_MODE_STENCIL or gui.CLIPPING_MODE_NONE)
	end)
end

--- 获取调试信息：返回水平数据列表和滚动视图的状态
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
