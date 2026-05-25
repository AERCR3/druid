local event = require("event.event")
local component = require("druid.component")
local storage = require("saver.storage")

local examples_list_view_item = require("example.components.examples_list_view.examples_list_view_item")

--- 示例列表面板组件：显示所有Druid示例的列表，支持选择、折叠和滚动
---@class examples_list_view: druid.component
---@field root druid.container
---@field druid druid.instance
---@field scroll druid.scroll
---@field grid druid.grid
local M = component.create("examples_list_view")


--- 初始化函数：创建滚动视图、网格布局和事件对象
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加标题锚点
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_header")

	-- 创建标题文本和示例项组件
	self.druid:new_lang_text("text_header", "ui_examples")
	self.druid:new(examples_list_view_item, "examples_list_view_item")

	-- 获取预制件并禁用，用于后续克隆
	self.prefab = self:get_node("examples_list_view_item/root")
	gui.set_enabled(self.prefab, false)

	-- 创建滚动视图和网格布局，并绑定在一起
	self.scroll = self.druid:new_scroll("scroll_view", "scroll_content")
	self.scroll.on_scroll:subscribe(self.on_scroll)
	self.grid = self.druid:new_grid("scroll_content", self.prefab, 1)
	self.scroll:bind_grid(self.grid)

	-- 创建滚动条滑块
	self.slider = self.druid:new_slider("scroll_bar_pin", vmath.vector3(-8, 48 - 850.0, 0), self.on_slider_change)
	self.slider:set_input_node("scroll_bar_view")

	-- 监听滚动视图尺寸变化，动态调整滚动区域和滑块位置
	self.root:add_container("scroll_view", nil, function(_, size)
		self.scroll:set_view_size(size)
		self.scroll:set_size(self.grid:get_size())
		self.slider:set_end_pos(vmath.vector3(-8, 48 - size.y, 0))
	end)

	self.selected_example = nil
	self.examples = {}
	-- 创建事件对象，用于与外部通信
	self.on_debug_info = event.create()
	self.on_set_information = event.create()
	self.add_log_text = event.create()

	-- 每0.1秒更新一次调试信息
	timer.delay(0.1, true, function()
		self:update_debug_info()
	end)
end

--- 示例实例类定义
---@class example_instance: druid.widget
---@field on_example_created fun(self: example_instance, output_list: output_list)?
---@field properties_control fun(self: example_instance, properties_panel: properties_panel)?
---@field get_debug_info fun(self: example_instance):string?

--- 添加示例到列表：为每个示例创建列表项并绑定点击事件
---@param examples druid.examples 示例数据
---@param druid_example druid.example 主界面组件
function M:add_example(examples, druid_example)
	local example_name_id = examples.example_name_id
	local examples_list = examples.examples_list

	if false then
		do -- 添加分组标题（示例里默认关闭）
			local nodes = gui.clone_tree(self.prefab)
			local item = self.druid:new(examples_list_view_item, "examples_list_view_item", nodes) --[[@as examples_list_view_item]]
			gui.set_enabled(item.root.node, true)
			item.text:translate(example_name_id)
			item:set_fold_icon_enabled(true)

			item.on_click:subscribe(function()
				item:set_fold_status(not item:is_folded())
			end)

			self.grid:add(item.root.node)
		end
	end

	-- 遍历示例列表，为每个示例创建列表项
	for index = 1, #examples_list do
		local example_data = examples_list[index]
		local nodes = gui.clone_tree(self.prefab)
		local item = self.druid:new(examples_list_view_item, "examples_list_view_item", nodes) --[[@as examples_list_view_item]]
		gui.set_enabled(item.root.node, true)
		item.text:translate(example_data.name_id)
		item:set_fold_icon_enabled(false)

		-- 订阅点击事件：选择示例并加载
		item.on_click:subscribe(function()
			-- 如果之前有选中的示例，先取消选中并移除
			if self.selected_example then
				self.selected_example.list_item:set_selected(false)
				druid_example.druid:remove(self.selected_example.instance)
				gui.set_enabled(self.selected_example.root, false)

				self.selected_example = nil
			end

			-- 这里的延迟用于处理“再次选择同一个示例”的情况
			-- 由于节点状态无法立刻恢复到初始状态，这里需要短暂让出一帧
			timer.delay(0, false, function()
				self:on_example_click(druid_example, example_data, item)

				-- 保存最后选择的示例ID
				storage.set("last_selected_example", example_data.name_id)
				-- 在网页平台下更新URL参数
				if html5 then
					local command = string.format('window.history.replaceState(null, null, "?example=%s")', example_data.name_id)
					html5.run(command)
				end
			end)
		end)

		self.grid:add(item.root.node)
		table.insert(self.examples, {
			data = example_data,
			list_item = item
		})
	end
end

--- 处理示例点击：创建并显示选中的示例实例
---@param druid_example druid.example 主界面组件
---@param example_data druid.example.data 示例数据
---@param item examples_list_view_item 列表项组件
function M:on_example_click(druid_example, example_data, item)
	-- 启用示例根节点
	local root = gui.get_node(example_data.root)
	gui.set_enabled(root, true)

	local instance
	-- 根据示例类型创建对应的实例（widget或component）
	if example_data.widget_class then
		instance = druid_example.druid:new_widget(example_data.widget_class, example_data.template)
	elseif example_data.component_class then -- 保持向后兼容
		instance = druid_example.druid:new(example_data.component_class, example_data.template)
	end
	---@cast instance example_instance

	-- 保存当前选中的示例信息
	self.selected_example = {
		data = example_data,
		list_item = item,
		instance = instance,
		root = root
	}
	item:set_selected(true)

	-- 清空输出列表
	druid_example.output_list:clear()
	-- 调用示例的on_example_created回调（如果存在）
	if instance.on_example_created then
		instance:on_example_created(druid_example.output_list)
	elseif example_data.on_create then
		example_data.on_create(instance, druid_example.output_list)
	end

	-- 设置信息面板的文本
	if example_data.information_text_id then
		self.on_set_information(example_data.information_text_id)
	else
		self.on_set_information("")
	end

	-- 设置GUI路径显示
	druid_example.example_scene:set_gui_path(example_data.code_url)

	-- 清空属性面板
	druid_example.properties_panel:clear()

	-- 优先使用示例实例提供的属性面板控制逻辑；否则尝试使用数据表里的回调
	if instance.properties_control then
		instance:properties_control(druid_example.properties_panel)
	elseif example_data.properties_control then
		example_data.properties_control(instance, druid_example.properties_panel)
	end
end

--- 根据名称ID选择示例：查找并选中指定ID的示例，滚动到对应位置
---@param name_id string 示例的名称ID
---@return boolean 如果找到并成功选中示例则返回 true（否则返回 false）
function M:select_example_by_name_id(name_id)
	-- 根据名称ID查找并选择对应的示例
	print("根据名称ID选择示例", name_id)
	for index = 1, #self.examples do
		local example = self.examples[index]

		-- 滚动到该条目附近
		local target_pos = gui.get_position(example.list_item.root.node)
		target_pos.y = target_pos.y + self.scroll.view_size.y / 2
		self.scroll:scroll_to(target_pos, true)

		-- 选中该条目
		if example.data.name_id == name_id then
			example.list_item.on_click:trigger()
			return true
		end
	end

	return false
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

--- 更新调试信息：获取当前选中示例的调试信息并触发事件
function M:update_debug_info()
	if not self.selected_example then
		self.on_debug_info:trigger("")
		return
	end

	local instance = self.selected_example.instance
	-- 如果示例实例提供了get_debug_info方法，调用它获取调试信息
	if instance.get_debug_info then
		local info = instance:get_debug_info()
		self.on_debug_info:trigger(info)
		return
	end

	local data = self.selected_example.data
	if data.get_debug_info then
		local info = data.get_debug_info(self.selected_example.instance)
		self.on_debug_info:trigger(info)
		return
	end

	self.on_debug_info:trigger("")
end

return M
