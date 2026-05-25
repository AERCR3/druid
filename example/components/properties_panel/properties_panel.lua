local component = require("druid.component")

local property_checkbox = require("example.components.properties_panel.properties.property_checkbox")
local property_slider = require("example.components.properties_panel.properties.property_slider")
local property_button = require("example.components.properties_panel.properties.property_button")

--- 属性面板组件：提供可滚动的属性控制面板，支持复选框、滑块和按钮
---@class properties_panel: druid.component
---@field root druid.container
---@field text_no_properties druid.lang_text
---@field scroll druid.scroll
---@field druid druid.instance
local M = component.create("properties_panel")

--- 初始化函数：创建滚动视图、网格布局和预制件引用
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加标题和分隔线锚点
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_header")
	self.root:add_container("separator")
	-- 如需在滚动视图尺寸变化时自动刷新滚动区域，可在这里为容器添加尺寸变化回调

	self.properties = {}

	-- 创建标题文本和无属性提示文本
	self.druid:new_lang_text("text_header", "ui_properties_panel")
	self.text_no_properties = self.druid:new_lang_text("text_no_properties", "ui_no_properties") --[[@as druid.lang_text]]

	-- 创建滚动视图和网格布局，并绑定在一起
	self.scroll = self.druid:new_scroll("scroll_view", "scroll_content")
	self.grid = self.druid:new_grid("scroll_content", "item_size", 1)
	self.scroll:bind_grid(self.grid)
	self.scroll.on_scroll:subscribe(self.on_scroll)
	self.grid.on_change_items:subscribe(self.on_grid_change_items)

	-- 创建滚动条滑块
	self.slider = self.druid:new_slider("scroll_bar_pin", vmath.vector3(-8, 48 - 290.0, 0), self.on_slider_change)
	self.slider:set_input_node("scroll_bar_view")

	-- 获取并禁用预制件节点，用于后续克隆
	self.property_checkbox_prefab = self:get_node("property_checkbox/root")
	gui.set_enabled(self.property_checkbox_prefab, false)

	self.property_slider_prefab = self:get_node("property_slider/root")
	gui.set_enabled(self.property_slider_prefab, false)

	self.property_button_prefab = self:get_node("property_button/root")
	gui.set_enabled(self.property_button_prefab, false)
end

--- 清空所有属性：移除所有属性组件和网格项
function M:clear()
	-- 移除所有属性组件
	for index = 1, #self.properties do
		self.druid:remove(self.properties[index])
	end
	self.properties = {}

	-- 删除所有网格节点
	local nodes = self.grid.nodes
	for index = 1, #nodes do
		gui.delete_node(nodes[index])
	end
	self.grid:clear()

	-- 显示无属性提示
	gui.set_enabled(self.text_no_properties.text.node, true)
end

--- 添加复选框属性：创建一个复选框控件并添加到网格中
---@param text_id string 文本ID（用于本地化）
---@param initial_value boolean 初始值
---@param on_change_callback function 值改变时的回调函数
---@return property_checkbox 返回复选框实例
function M:add_checkbox(text_id, initial_value, on_change_callback)
	-- 创建复选框组件实例
	local instance = self.druid:new_widget(property_checkbox, "property_checkbox", self.property_checkbox_prefab) --[[@as property_checkbox]]
	instance.text_name:translate(text_id)
	instance:set_value(initial_value, true)
	-- 订阅点击事件，触发回调
	instance.button.on_click:subscribe(function()
		on_change_callback(instance:get_value())
	end)

	gui.set_enabled(instance.root.node, true)
	self.grid:add(instance.root.node)
	table.insert(self.properties, instance)
	gui.set_enabled(self.text_no_properties.text.node, false)

	return instance
end

--- 添加滑块属性：创建一个滑块控件并添加到网格中
---@param text_id string 文本ID（用于本地化）
---@param initial_value number 初始值
---@param on_change_callback function 值改变时的回调函数
---@return property_slider 返回滑块实例
function M:add_slider(text_id, initial_value, on_change_callback)
	-- 创建滑块组件实例
	local instance = self.druid:new_widget(property_slider, "property_slider", self.property_slider_prefab) --[[@as property_slider]]
	instance.text_name:translate(text_id)
	instance:set_value(initial_value, true)

	gui.set_enabled(instance.root.node, true)
	self.grid:add(instance.root.node)
	table.insert(self.properties, instance)
	gui.set_enabled(self.text_no_properties.text.node, false)

	-- 订阅滑块值改变事件，触发回调
	instance.slider.on_change_value:subscribe(function(_, value)
		on_change_callback(value)
	end)

	return instance
end

--- 添加按钮属性：创建一个按钮控件并添加到网格中
---@param text_id string 文本ID（用于本地化）
---@param on_click_callback function 点击时的回调函数
function M:add_button(text_id, on_click_callback)
	-- 创建按钮组件实例
	local instance = self.druid:new_widget(property_button, "property_button", self.property_button_prefab) --[[@as property_button]]
	instance.text_name:translate(text_id)

	gui.set_enabled(instance.root, true)
	self.grid:add(instance.root)
	table.insert(self.properties, instance)
	gui.set_enabled(self.text_no_properties.text.node, false)

	-- 订阅按钮点击事件
	instance.button.on_click:subscribe(on_click_callback)

	return instance
end

--- 滑块改变回调：根据滑块值滚动到对应位置
---@param value number 滑块值，范围 [0..1]
function M:on_slider_change(value)
	self.scroll:scroll_to_percent(vmath.vector3(0, 1 - value, 0), true)
end

--- 滚动事件回调：同步滑块位置与滚动进度
function M:on_scroll()
	local scroll_percent = self.scroll:get_percent()
	self.slider:set(1 - scroll_percent.y, true)
end

--- 网格项改变回调：根据是否可滚动显示/隐藏滑块，并同步滑块位置
function M:on_grid_change_items()
	local is_scroll_available = self.scroll.drag.can_y
	gui.set_enabled(self.slider.node, is_scroll_available)
	if is_scroll_available then
		local scroll_percent = self.scroll:get_percent()
		self.slider:set(1 - scroll_percent.y, true)
	end
end

return M
