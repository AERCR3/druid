--- 滚动滑块示例：展示滚动视图与滑块控件的联动
---@class examples.scroll_slider: druid.widget
---@field root node
---@field scroll druid.scroll
---@field slider druid.slider
local M = {}

--- 初始化函数：创建滚动视图、滑块和多个按钮
function M:init()
	-- 创建滚动视图并订阅滚动事件
	self.scroll = self.druid:new_scroll("scroll_view", "scroll_content")
	self.scroll.on_scroll:subscribe(self.on_scroll)

	-- 创建滑块控件，用于同步滚动位置
	self.slider = self.druid:new_slider("slider_pin", vmath.vector3(-8, -976, 0), self.on_slider) --[[@as druid.slider]]
	self.slider:set_input_node("slider_back")

	-- 滑块背景悬停效果
	self.druid:new_hover("slider_back", nil, self.on_slider_back_hover)

	-- 创建13个按钮，点击可滚动到对应位置
	for index = 1, 13 do
		self.druid:new_button("button" .. index .. "/root", self.on_button_click, index)
	end
end

--- 滚动事件回调：同步滑块位置与滚动进度
function M:on_scroll()
	local scroll_percent = self.scroll:get_percent()
	self.slider:set(1 - scroll_percent.y, true)
end

--- 滑块值改变回调：根据滑块值滚动到对应位置
---@param value number 滑块值
function M:on_slider(value)
	self.scroll:scroll_to_percent(vmath.vector3(0, 1 - value, 0), true)
end

--- 按钮点击回调：滚动到对应按钮位置
---@param params any 按钮参数（索引）
---@param button druid.button 按钮实例
function M:on_button_click(params, button)
	-- 打印按钮点击信息，包含参数和按钮对象
	print("按钮点击", params, button)
	local node = button.node
	self.scroll:scroll_to(gui.get_position(node))
end

--- 滑块背景悬停回调：根据悬停状态改变滑块透明度
---@param is_hover boolean 是否悬停
function M:on_slider_back_hover(is_hover)
	local node = self:get_node("slider_pin")
	gui.animate(node, "color.w", is_hover and 1.5 or 1, gui.EASING_OUTSINE, 0.2)
end

--- 获取调试信息：返回滚动视图的状态信息
---@return string
function M:get_debug_info()
	local info = ""

	local s = self.scroll
	-- 构建滚动视图的调试信息
	info = info .. "视图大小 Y: " .. gui.get(s.view_node, "size.y") .. "\n"
	info = info .. "内容大小 Y: " .. gui.get(s.content_node, "size.y") .. "\n"
	info = info .. "内容位置 Y: " .. math.ceil(s.position.y) .. "\n"
	info = info .. "内容范围 Y: " .. s.available_pos.y .. " - " .. s.available_pos.w .. "\n"

	return info
end

return M
