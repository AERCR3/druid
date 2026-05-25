local event = require("event.event")
local component = require("druid.component")
local storage = require("saver.storage")

local examples_list_view_item = require("example.components.examples_list_view.examples_list_view_item")

---@class examples_list_view: druid.component
---@field root druid.container
---@field druid druid.instance
---@field scroll druid.scroll
---@field grid druid.grid
local M = component.create("examples_list_view")


---@param template string
---@param nodes table<hash, node>
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_header")

	self.druid:new_lang_text("text_header", "ui_examples")
	self.druid:new(examples_list_view_item, "examples_list_view_item")

	self.prefab = self:get_node("examples_list_view_item/root")
	gui.set_enabled(self.prefab, false)

	self.scroll = self.druid:new_scroll("scroll_view", "scroll_content")
	self.scroll.on_scroll:subscribe(self.on_scroll)
	self.grid = self.druid:new_grid("scroll_content", self.prefab, 1)
	self.scroll:bind_grid(self.grid)

	self.slider = self.druid:new_slider("scroll_bar_pin", vmath.vector3(-8, 48-850.0, 0), self.on_slider_change)
	self.slider:set_input_node("scroll_bar_view")

	self.root:add_container("scroll_view", nil, function(_, size)
		self.scroll:set_view_size(size)
		self.scroll:set_size(self.grid:get_size())
		self.slider:set_end_pos(vmath.vector3(-8, 48-size.y, 0))
	end)

	self.selected_example = nil
	self.examples = {}
	self.on_debug_info = event.create()
	self.on_set_information = event.create()
	self.add_log_text = event.create()

	timer.delay(0.1, true, function()
		self:update_debug_info()
	end)
end

---@class example_instance: druid.widget
---@field on_example_created fun(self: example_instance, output_list: output_list)?
---@field properties_control fun(self: example_instance, properties_panel: properties_panel)?
---@field get_debug_info fun(self: example_instance):string?

---@param examples druid.examples
---@param druid_example druid.example @主界面组件
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

	for index = 1, #examples_list do
		local example_data = examples_list[index]
		local nodes = gui.clone_tree(self.prefab)
		local item = self.druid:new(examples_list_view_item, "examples_list_view_item", nodes) --[[@as examples_list_view_item]]
		gui.set_enabled(item.root.node, true)
		item.text:translate(example_data.name_id)
		item:set_fold_icon_enabled(false)

		item.on_click:subscribe(function()
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

				storage.set("last_selected_example", example_data.name_id)
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


---@param druid_example druid.example
---@param example_data druid.example.data
---@param item examples_list_view_item
function M:on_example_click(druid_example, example_data, item)
	local root = gui.get_node(example_data.root)
	gui.set_enabled(root, true)

	local instance
	if example_data.widget_class then
		instance = druid_example.druid:new_widget(example_data.widget_class, example_data.template)
	elseif example_data.component_class then -- 保持向后兼容
		instance = druid_example.druid:new(example_data.component_class, example_data.template)
	end
	---@cast instance example_instance

	self.selected_example = {
		data = example_data,
		list_item = item,
		instance = instance,
		root = root
	}
	item:set_selected(true)

	druid_example.output_list:clear()
	if instance.on_example_created then
		instance:on_example_created(druid_example.output_list)
	elseif example_data.on_create then
		example_data.on_create(instance, druid_example.output_list)
	end

	if example_data.information_text_id then
		self.on_set_information(example_data.information_text_id)
	else
		self.on_set_information("")
	end

	druid_example.example_scene:set_gui_path(example_data.code_url)

	druid_example.properties_panel:clear()

	-- 优先使用示例实例提供的属性面板控制逻辑；否则尝试使用数据表里的回调
	if instance.properties_control then
		instance:properties_control(druid_example.properties_panel)
	elseif example_data.properties_control then
		example_data.properties_control(instance, druid_example.properties_panel)
	end
end


---@param name_id string
---@return boolean @如果找到并成功选中示例则返回 true（否则返回 false）
function M:select_example_by_name_id(name_id)
	print("Select example by name_id", name_id)
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


---@param value number in range [0..1]
function M:on_slider_change(value)
	self.scroll:scroll_to_percent(vmath.vector3(0, 1 - value, 0), true)
end


function M:on_scroll()
	local scroll_percent = self.scroll:get_percent()
	self.slider:set(1 - scroll_percent.y, true)
end


function M:update_debug_info()
	if not self.selected_example then
		self.on_debug_info:trigger("")
		return
	end

	local instance = self.selected_example.instance
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
