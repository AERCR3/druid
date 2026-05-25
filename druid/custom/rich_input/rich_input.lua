local component         = require("druid.component")
local helper            = require("druid.helper")
local const             = require("druid.const")
local utf8_lua          = require("druid.system.utf8")
local utf8              = utf8 or utf8_lua

---处理富文本输入字段的组件，它是druid.input组件的包装器
---富文本输入组件提供了增强的文本输入功能，支持更复杂的文本编辑操作
---@class druid.rich_input: druid.component
---@field root node 富输入的根节点
---@field input druid.input 输入组件
---@field cursor node 光标节点
---@field cursor_text node 光标文本节点
---@field cursor_position vector3 光标的位置
local M                 = component.create("druid.rich_input")

local DOUBLE_CLICK_TIME = 0.35

local function animate_cursor(self)
	gui.cancel_animations(self.cursor_text, "color.w")
	gui.set_alpha(self.cursor_text, 1)
	gui.animate(self.cursor_text, "color.w", 0, gui.EASING_INSINE, 0.8, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
end


local function set_selection_width(self, selection_width)
	gui.set_visible(self.cursor, selection_width > 0)

	local width = selection_width / self.input.text.scale.x
	local height = gui.get_size(self.cursor).y
	gui.set_size(self.cursor, vmath.vector3(width, height, 0))

	local is_selection_to_right = self.input.cursor_index == self.input.end_index
	gui.set_pivot(self.cursor, is_selection_to_right and gui.PIVOT_E or gui.PIVOT_W)
end


---更新文本显示和光标位置
---此函数根据当前输入内容更新文本显示和光标位置
---@param self druid.rich_input 富输入组件实例
local function update_text(self)
	local full_text = self.input:get_text()
	local visible_text = self.input.text:get_text()

	local is_truncated = visible_text ~= full_text
	local cursor_index = self.input.cursor_index
	if is_truncated then
		-- If text is truncated, we need to adjust the cursor index
		-- to the last visible character
		cursor_index = utf8.len(visible_text)
	end

	local left_text_part = utf8.sub(self.input:get_text(), 0, cursor_index)
	local selected_text_part = utf8.sub(self.input:get_text(), self.input.start_index + 1, self.input.end_index)

	local left_part_width = self.input.text:get_text_size(left_text_part)
	local selected_part_width = self.input.text:get_text_size(selected_text_part)

	local pivot_text = gui.get_pivot(self.input.text.node)
	local pivot_offset = helper.get_pivot_offset(pivot_text)

	self.cursor_position.x = self.text_position.x - self.input.text_width * (0.5 + pivot_offset.x) + left_part_width

	gui.set_position(self.cursor, self.cursor_position)
	gui.set_scale(self.cursor, self.input.text.scale)

	set_selection_width(self, selected_part_width)
end


local function on_select(self)
	gui.set_enabled(self.cursor, true)
	gui.set_enabled(self.placeholder.node, false)
	gui.set_enabled(self.input.button.node, true)

	animate_cursor(self)
	self.drag:set_enabled(true)

	-- We want to catch events here first
	self:set_input_priority(const.PRIORITY_INPUT_MAX, true)
	self.input:set_input_priority(const.PRIORITY_INPUT_MAX - 1, true)
end


local function on_unselect(self)
	gui.cancel_animations(self.cursor, gui.PROP_COLOR)
	gui.set_enabled(self.cursor, false)
	gui.set_enabled(self.input.button.node, self.is_button_input_enabled)
	gui.set_enabled(self.placeholder.node, true and #self.input:get_text() == 0)

	self.drag:set_enabled(false)

	self:reset_input_priority()
	self.input:reset_input_priority()
end


---更新选择
---此函数更新当前文本选择状态
local function update_selection(self)
	update_text(self)
end


local TEMP_VECTOR = vmath.vector3(0)
local function get_index_by_touch(self, touch)
	local text_node = self.input.text.node
	TEMP_VECTOR.x = touch.screen_x
	TEMP_VECTOR.y = touch.screen_y

	-- Distance to the text node position
	local scene_scale = helper.get_scene_scale(text_node)
	local local_pos = gui.screen_to_local(text_node, TEMP_VECTOR)
	local_pos.x = local_pos.x / scene_scale.x

	-- Offset to the left side of the text node
	local pivot_offset = helper.get_pivot_offset(gui.get_pivot(text_node))
	local_pos.x = local_pos.x + self.input.total_width * (0.5 + pivot_offset.x)
	local_pos.x = local_pos.x - self.text_position.x

	local cursor_index = self.input.text:get_text_index_by_width(local_pos.x)
	return cursor_index
end


local function on_touch_start_callback(self, touch)
	local cursor_index = get_index_by_touch(self, touch)

	if self._last_touch_info.cursor_index == cursor_index then
		local time = socket.gettime()
		if time - self._last_touch_info.time < DOUBLE_CLICK_TIME then
			local len = utf8.len(self.input:get_text())
			self.input:select_cursor(len, 0, len)
			self._last_touch_info.cursor_index = nil

			return
		end
	end

	self._last_touch_info.cursor_index = cursor_index
	self._last_touch_info.time = socket.gettime()

	if self.input.is_lshift then
		local start_index = self.input.start_index
		local end_index = self.input.end_index

		if cursor_index < start_index then
			self.input:select_cursor(cursor_index, cursor_index, end_index)
		elseif cursor_index > end_index then
			self.input:select_cursor(cursor_index, start_index, cursor_index)
		end
	else
		self.input:select_cursor(cursor_index)
	end
end


---@param self druid.rich_input 富输入组件实例
---@param dx number X位置增量
---@param dy number Y位置增量
---@param x number X位置
---@param y number Y位置
---@param touch table 触摸表
local function on_drag_callback(self, dx, dy, x, y, touch)
	if not self._last_touch_info.cursor_index then
		return
	end

	local index = get_index_by_touch(self, touch)
	if self._last_touch_info.cursor_index <= index then
		self.input:select_cursor(index, self._last_touch_info.cursor_index, index)
	else
		self.input:select_cursor(index, index, self._last_touch_info.cursor_index)
	end
end


---@param template string 模板字符串名称
---@param nodes table 来自gui.clone_tree的节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)
	self.root = self:get_node("root")

	self._last_touch_info = {
		cursor_index = nil,
		time = 0,
	}
	self.is_lshift = false
	self.is_lctrl = false

	self.input = self.druid:new_input("button", "input_text")
	self.is_button_input_enabled = gui.is_enabled(self.input.button.node)

	self.cursor = self:get_node("cursor_node")
	self.cursor_position = gui.get_position(self.cursor)
	self.cursor_text = self:get_node("cursor_text")

	self.drag = self.druid:new_drag("button", on_drag_callback)
	self.drag.on_touch_start:subscribe(on_touch_start_callback)
	self.drag:set_input_priority(const.PRIORITY_INPUT_MAX + 1)
	self.drag:set_enabled(false)

	self.input:set_text("")
	self.placeholder = self.druid:new_text("placeholder_text")
	self.text_position = gui.get_position(self.input.text.node)

	self.input.on_input_text:subscribe(update_text)
	self.input.on_input_select:subscribe(on_select)
	self.input.on_input_unselect:subscribe(on_unselect)
	self.input.on_select_cursor_change:subscribe(update_selection)

	on_unselect(self)
	update_text(self)
end

---@private
---@param action_id hash 来自on_input的动作ID
---@param action table 来自on_input的动作表
---@return boolean is_consumed 如果输入被消耗则返回true
function M:on_input(action_id, action)
	if action_id == const.ACTION_LSHIFT then
		if action.pressed then
			self.is_lshift = true
		elseif action.released then
			self.is_lshift = false
		end
	end

	if action_id == const.ACTION_LCTRL or action_id == const.ACTION_LCMD then
		if action.pressed then
			self.is_lctrl = true
		elseif action.released then
			self.is_lctrl = false
		end
	end

	if self.input.is_selected then
		if action_id == const.ACTION_LEFT and (action.pressed or action.repeated) then
			self.input:move_selection(-1, self.is_lshift, self.is_lctrl)
			return true
		end

		if action_id == const.ACTION_RIGHT and (action.pressed or action.repeated) then
			self.input:move_selection(1, self.is_lshift, self.is_lctrl)
			return true
		end
	end

	return false
end

---设置占位符文本
---@param placeholder_text string 占位符文本
---@return druid.rich_input self 当前实例
function M:set_placeholder(placeholder_text)
	self.placeholder:set_text(placeholder_text)
	return self
end

---选择输入字段
---@return druid.rich_input self 当前实例
function M:select()
	self.input:select()
	return self
end

---设置输入字段文本
---@param text string 输入文本
---@return druid.rich_input self 当前实例
function M:set_text(text)
	self.input:set_text(text)
	gui.set_enabled(self.placeholder.node, true and #self.input:get_text() == 0)

	return self
end

---设置输入字段字体
---@param font hash 字体哈希值
---@return druid.rich_input self 当前实例
function M:set_font(font)
	gui.set_font(self.input.text.node, font)
	gui.set_font(self.placeholder.node, font)

	return self
end

---获取输入字段文本
function M:get_text()
	return self.input:get_text()
end

---设置输入字段允许的字符。
-- 参考：https://defold.com/ref/stable/string/
-- 示例：[%a%d] 用于字母和数字
---@param characters string 用于验证用户输入的正则表达式
---@return druid.rich_input self 当前实例
function M:set_allowed_characters(characters)
	self.input:set_allowed_characters(characters)

	return self
end

return M
