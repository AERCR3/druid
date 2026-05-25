local helper = require("druid.helper")

--- 多行文本示例：展示可拖拽调整大小的多行文本区域，支持不同锚点和文本调整模式
---@class examples.multiline_text: druid.widget
---@field root node
local M = {}

--- 初始化函数：创建文本组件和可拖拽的容器
function M:init()
	self.root = self:get_node("root")
	-- 创建文本组件
	self.text = self.druid:new_text("text")

	-- 允许用鼠标拖拽调整文本区域大小（容器尺寸变化时同步更新文本布局）
	self.container = self.druid:new_container("text_area", nil, function(_, size)
		self.text:set_size(size)
		self:refresh_text_position()
	end) --[[@as druid.container]]

	-- 为容器创建可拖拽的角落
	self.container:create_draggable_corners()
end

--- 设置文本锚点：更改文本的pivot并重新计算位置
---@param pivot constant 要设置的锚点
function M:set_pivot(pivot)
	self.text:set_pivot(pivot)
	self:refresh_text_position()
end

--- 刷新文本位置：根据当前pivot重新计算文本节点的位置
function M:refresh_text_position()
	-- 不同 pivot 下文本的锚点位置不同，需要重新计算文本节点的位置
	local pivot = gui.get_pivot(self.text.node)
	local pivot_offset = helper.get_pivot_offset(pivot)
	gui.set_position(self.text.node,
		vmath.vector3(pivot_offset.x * self.text.start_size.x, pivot_offset.y * self.text.start_size.y, 0))
end

--- 属性面板控制：添加切换文本调整模式和锚点的按钮
---@param properties_panel properties_panel 属性面板实例
function M:properties_control(properties_panel)
	local adjust_index = 1
	local adjust_types = {
		"downscale",
		"downscale_limited",
		--"scale_then_scroll", -- 与 container 配合时效果不理想（示例暂不展示）
		--"scroll", -- 与 container 配合时效果不理想（示例暂不展示）
		"trim",
	}
	-- 添加切换文本调整模式的按钮
	properties_panel:add_button("ui_adjust_next", function()
		adjust_index = adjust_index + 1
		if adjust_index > #adjust_types then
			adjust_index = 1
		end
		self.text:set_text_adjust(adjust_types[adjust_index], 0.8)
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

	-- 添加切换锚点的按钮
	properties_panel:add_button("ui_pivot_next", function()
		pivot_index = pivot_index + 1
		if pivot_index > #pivot_list then
			pivot_index = 1
		end
		self:set_pivot(pivot_list[pivot_index])
	end)
end

--- 获取调试信息：返回当前文本调整模式和锚点信息
---@return string 调试信息字符串
function M:get_debug_info()
	local info = ""

	info = info .. "Text Adjust: " .. self.text.adjust_type .. "\n"
	info = info .. "Pivot: " .. gui.get_pivot(self.text.node) .. "\n"

	return info
end

return M
