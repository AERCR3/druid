local helper = require("druid.helper")
local druid_const = require("druid.const")

--- 悬停提示示例：鼠标悬停在元素上时显示提示框
---@class examples.hover_hint: druid.widget
---@field root node
---@field panel_hint node
---@field text_hint druid.text
---@field hovers druid.hover[]
---@field is_shown boolean
---@field private _hint_text string
---@field private _hover_timer_id hash
local M = {}

-- 延迟显示提示的时间（秒）
local TIMER_DELAY = 0.5
-- 提示框最小宽度
local MIN_PANEL_WIDTH = 100
-- 提示框最小高度
local MIN_PANEL_HEIGHT = 50
-- 提示框内边距
local PANEL_MARGIN = 40
-- 提示框与触发元素的偏移距离
local HINT_OFFSET = 20

--- 初始化函数：创建提示框组件并设置初始状态
function M:init()
	self.root = self:get_node("root")
	self.panel_hint = self:get_node("panel_hint")
	self.text_hint = self.druid:new_text("text_hint")

	self.hovers = {}
	self._timer_id = nil
	self.is_shown = false

	-- 初始时隐藏提示框
	gui.set_enabled(self.root, false)
end

--- 添加悬停提示：为指定节点绑定悬停事件，延迟显示提示框
---@param node node|string 触发悬停的节点或节点ID
---@param hint_text string 提示文本内容
---@param pivot_point constant 触发节点的锚点位置
---@param content_pivot constant 提示框内容的锚点位置
function M:add_hover_hint(node, hint_text, pivot_point, content_pivot)
	-- 创建悬停组件，监听鼠标进入/离开事件
	local hover = self.druid:new_hover(node, nil, function(_, is_hover)
		-- 鼠标状态改变时先隐藏当前提示
		self:hide_hint()

		if is_hover then
			-- 鼠标进入时，延迟 TIMER_DELAY 秒后显示提示框
			self._timer_id = timer.delay(TIMER_DELAY, false, function()
				self._timer_id = nil
				self:show_hint(node, hint_text, pivot_point, content_pivot)
			end)
		end
	end)

	table.insert(self.hovers, hover)
end

--- 隐藏提示框：取消定时器并淡出提示框
function M:hide_hint()
	-- 如果有待执行的定时器，取消它
	if self._timer_id then
		timer.cancel(self._timer_id)
		self._timer_id = nil
	end

	-- 如果提示框正在显示，执行淡出动画
	if self.is_shown then
		self.is_shown = false
		gui.animate(self.root, "color.w", 0, gui.EASING_OUTSINE, 0.2, 0, function()
			gui.set_enabled(self.root, false)
		end)
	end
end

--- 显示提示框：刷新内容并执行淡入动画
---@param hint_text string 提示文本内容
---@param pivot_point constant 触发节点的锚点位置
---@param content_pivot constant 提示框内容的锚点位置
function M:show_hint(node, hint_text, pivot_point, content_pivot)
	-- 刷新提示框内容和位置
	self:refresh_content(node, hint_text, pivot_point, content_pivot)

	self.is_shown = true

	do -- 显示动画：启用节点并淡入
		gui.set_enabled(self.root, true)
		gui.set_alpha(self.root, 0)
		gui.animate(self.root, "color.w", 1, gui.EASING_OUTSINE, 0.2)
	end
end

--- 刷新提示框内容：根据文本长度调整提示框大小
---@private
function M:refresh_content(node, hint_text, pivot_point, content_pivot)
	-- 设置提示文本
	self.text_hint:set_text(hint_text)
	local text_width, text_height = self.text_hint:get_text_size()

	-- 计算提示框尺寸，确保不小于最小尺寸
	local panel_width = math.max(text_width, MIN_PANEL_WIDTH) + PANEL_MARGIN
	local panel_height = math.max(text_height, MIN_PANEL_HEIGHT) + PANEL_MARGIN

	gui.set(self.root, "size.x", panel_width)
	gui.set(self.root, "size.y", panel_height)
	gui.set(self.panel_hint, "size.x", panel_width)
	gui.set(self.panel_hint, "size.y", panel_height)

	-- 刷新提示框位置
	self:refresh_position(node, pivot_point, content_pivot)
end

--- 刷新提示框位置：根据触发节点和锚点计算提示框的最终位置
---@private
---@param node node 触发节点
---@param pivot_point constant 触发节点的锚点位置
---@param content_pivot constant 提示框内容的锚点位置
function M:refresh_position(node, pivot_point, content_pivot)
	-- 获取触发节点的屏幕坐标和尺寸
	local screen_position = gui.get_screen_position(node)
	local node_size = gui.get_size(node)
	node_size.x = node_size.x + HINT_OFFSET * 2
	node_size.y = node_size.y + HINT_OFFSET * 2

	-- 计算触发节点的偏移（根据触发节点自身 pivot 计算）
	local offset = -vmath.mul_per_elem(node_size, druid_const.PIVOTS[gui.get_pivot(node)])

	-- 从中心偏移到目标 pivot 点
	offset = offset + vmath.mul_per_elem(node_size, druid_const.PIVOTS[pivot_point])

	-- 计算提示框自身 pivot 的偏移
	local hint_size = gui.get_size(self.root)
	offset = offset - vmath.mul_per_elem(hint_size, druid_const.PIVOTS[content_pivot])

	-- 计算并设置最终位置：将屏幕坐标转换为本地坐标
	local world_scale = helper.get_scene_scale(self.root)
	local local_pos = gui.screen_to_local(self.root, screen_position) / world_scale.x
	gui.set_position(self.root, local_pos)

	-- 应用偏移量得到最终位置
	local position = gui.get_position(self.root)
	if offset then
		position = position + offset
	end
	gui.set_position(self.root, position)
end

return M
