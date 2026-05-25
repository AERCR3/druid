local helper = require("druid.helper")
local layout = require("druid.extended.layout")

--- 基础布局示例：展示Druid布局系统的水平换行布局功能
---@class examples.basic_layout: druid.widget
---@field root node
---@field layout druid.layout
---@field prefab node
---@field nodes table<number, node>
local M = {}

-- 支持的锚点列表，用于测试不同锚点效果
local PIVOTS = {
	gui.PIVOT_CENTER,
	gui.PIVOT_N,
	gui.PIVOT_NE,
	gui.PIVOT_E,
	gui.PIVOT_SE,
	gui.PIVOT_S,
	gui.PIVOT_SW,
	gui.PIVOT_W,
	gui.PIVOT_NW,
}


function M:init()
	self.root = self:get_node("root")
	self.layout = self.druid:new(layout, "layout", "horizontal_wrap")

	self.prefab = self:get_node("prefab")
	gui.set_enabled(self.prefab, false)
	local default_size = gui.get_size(self.prefab)

	self.nodes = {}

	for _ = 1, 12 do
		local node = gui.clone(self.prefab)

		-- 为部分节点设置不同尺寸，方便观察布局换行/对齐效果
		if math.random() > 0.5 then
			local size = vmath.vector3(default_size.x * 2, default_size.y, 0)
			gui.set_size(node, size)
		end

		-- 为每个节点随机设置 pivot，演示 pivot 对布局的影响
		local pivot = PIVOTS[math.random(1, #PIVOTS)]
		gui.set_pivot(node, pivot)

		gui.set_enabled(node, true)
		self.layout:add(node)
		table.insert(self.nodes, node)
	end
end

function M:set_pivot(pivot)
	local offset = helper.get_pivot_offset(pivot)
	local size = gui.get_size(self.root)
	local pos = vmath.vector3(size.x * offset.x, size.y * offset.y, 0)
	gui.set_position(self.layout.node, pos)
	gui.set_pivot(self.layout.node, pivot)

	self.layout:refresh_layout()
end

function M:on_remove()
	self.layout:clear_layout()
	for _, node in ipairs(self.nodes) do
		gui.delete_node(node)
	end
end

---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	properties_panel:add_slider("ui_padding", 0, function(value)
		local padding = math.floor((value * 64) * 100) / 100
		self.layout:set_padding(padding, padding, padding, padding)
	end)

	properties_panel:add_slider("ui_margin_x", 0, function(value)
		local margin = math.floor((value * 64) * 100) / 100
		self.layout:set_margin(margin, nil)
	end)

	properties_panel:add_slider("ui_margin_y", 0, function(value)
		local margin = math.floor((value * 64) * 100) / 100
		self.layout:set_margin(nil, margin)
	end)

	properties_panel:add_checkbox("ui_justify", false, function(value)
		self.layout:set_justify(value)
	end)

	local pivot_index = 1
	local pivot_list = {
		gui.PIVOT_CENTER,
		gui.PIVOT_W,
		gui.PIVOT_SW,
		gui.PIVOT_S,
		gui.PIVOT_SE,
		gui.PIVOT_E,
		gui.PIVOT_NE,
		gui.PIVOT_N,
		gui.PIVOT_NW,
	}

	properties_panel:add_button("ui_pivot_next", function()
		pivot_index = pivot_index + 1
		if pivot_index > #pivot_list then
			pivot_index = 1
		end
		self:set_pivot(pivot_list[pivot_index])
	end)

	local type_index = 1
	local type_list = {
		"horizontal_wrap",
		"horizontal",
		"vertical",
	}

	properties_panel:add_button("ui_type_next", function()
		type_index = type_index + 1
		if type_index > #type_list then
			type_index = 1
		end
		self.layout:set_type(type_list[type_index])
	end)
end

---@return string
function M:get_debug_info()
	local layout = self.layout
	local p = layout.padding
	local info = ""
	-- 构建布局的调试信息
	info = info .. "布局类型: " .. layout.type .. "\n"
	info = info ..
			"内边距: " .. math.floor(p.x) .. " " .. math.floor(p.y) .. " " .. math.floor(p.z) .. " " .. math.floor(p.w) .. "\n"
	info = info .. "外边距: " .. layout.margin.x .. " " .. layout.margin.y .. "\n"
	info = info .. "对齐: " .. tostring(layout.is_justify) .. "\n"
	info = info .. "锚点: " .. tostring(gui.get_pivot(layout.node)) .. "\n"

	return info
end

return M
