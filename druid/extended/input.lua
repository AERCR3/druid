local event = require("event.event")
local const = require("druid.const")
local helper = require("druid.helper")
local component = require("druid.component")
local utf8_lua = require("druid.system.utf8")
local utf8 = utf8 or utf8_lua

---@class druid.input.style
---@field MASK_DEFAULT_CHAR string 密码输入的默认字符掩码
---@field IS_LONGTAP_ERASE boolean 长按是否擦除当前输入数据
---@field IS_UNSELECT_ON_RESELECT boolean 如果为真，在选择已选中的输入时调用取消选择
---@field on_init fun(self: druid.input)|nil 输入初始化时的回调，用于在自身上设置自定义属性
---@field on_select fun(self: druid.input, button_node: node) 选择输入字段时的回调
---@field on_unselect fun(self: druid.input, button_node: node) 取消选择输入字段时的回调
---@field on_input_wrong fun(self: druid.input, button_node: node) 用户输入错误时的回调

---基本的Druid文本输入组件
---输入组件提供了完整的文本输入功能，支持密码掩码、字符验证、光标控制等高级特性
---通过点击按钮来激活/取消激活输入状态，配合GUI系统处理键盘输入
---
---### 设置方法
---使用druid创建输入组件：`input = druid:new_input(button_node_name, text_node_name, keyboard_type)`
--- button_node_name是用于激活输入的按钮节点名称
--- text_node_name是显示用户输入的文本节点名称
--- keyboard_type是可选的键盘类型设置
---
---### 主要特性
---- 输入组件结合了按钮交互和文本显示功能
---- 通过点击按钮选择/取消选择输入字段
---- 支持点击外部区域取消输入选择
---- 自动处理应用失去焦点时的输入状态清理
---- 可设置最大文本长度和允许的字符类型
---- 当用户输入不允许的字符时会触发错误回调
---
---### 应用场景
---- 密码输入框（支持字符掩码）
---- 普通文本输入（用户名、搜索框等）
---- 数字输入（限制字符类型）
---- 邮箱验证输入（特定格式验证）
---@class druid.input: druid.component
---@field on_input_select event fun(self: druid.input, input: druid.input) 选择输入字段时触发的事件
---@field on_input_unselect event fun(self: druid.input, text: string, input: druid.input) 取消选择输入字段时触发的事件
---@field on_input_text event fun(self: druid.input) 输入字段更改时触发的事件
---@field on_input_empty event fun(self: druid.input) 输入字段为空时触发的事件
---@field on_input_full event fun(self: druid.input) 输入字段满时触发的事件
---@field on_input_wrong event fun(self: druid.input) 输入字段错误时触发的事件
---@field on_select_cursor_change event fun(self: druid.input, cursor_index: number, start_index: number, end_index: number) 光标索引更改时触发的事件
---@field style druid.input.style 输入组件的样式
local M = component.create("input")

---@private
M.ALLOWED_ACTIONS = {
	[const.ACTION_TOUCH] = true,
	[const.ACTION_TEXT] = true,
	[const.ACTION_MARKED_TEXT] = true,
	[const.ACTION_BACKSPACE] = true,
	[const.ACTION_ENTER] = true,
	[const.ACTION_ESC] = true,
}

---文本掩码函数
---通过用指定的掩码字符替换每个字符来隐藏原始文本内容
---此函数主要用于密码输入框，显示为星号或其他掩码字符
---@param text string 要掩码的原始文本
---@param mask string|nil 掩码字符，默认为星号"*"
--- 可以使用任意字符作为掩码，如"*"、"●"、"#"等
---@return string 掩码后的文本
--- 所有字符都被替换为掩码字符的文本
local function mask_text(text, mask)
	--- 设置默认掩码字符为星号
	mask = mask or "*"
	local masked_text = ""
	--- 使用UTF8遍历文本的每个字符
	--- 这确保正确处理中文等多字节字符
	for uchar in utf8.gmatch(text, ".") do
		--- 将每个字符替换为掩码字符
		masked_text = masked_text .. mask
	end

	--- 返回完全掩码的文本
	return masked_text
end


local function clear_and_select(self)
	if self.style.IS_LONGTAP_ERASE then
		self:set_text("")
	end

	self:select()
end


---输入组件的构造函数
---初始化输入组件实例，设置点击节点、文本节点和键盘配置
---这是使用输入组件时调用的第一个方法，完成基础配置
---@param click_node node 激活输入组件的按钮节点
--- 用户点击此节点将选择/取消选择输入字段
---@param text_node node|druid.text 显示用户输入的文本节点
--- 可以是节点名称字符串，也可以是已存在的druid.text组件实例
--- 如果传递文本组件，则可以直接复用现有文本组件的功能
---@param keyboard_type constant|nil 输入字段的GUI键盘类型
--- 指定显示给用户的键盘类型（如TEXT_INPUT_TYPE_DEFAULT、TEXT_INPUT_TYPE_EMAIL等）
function M:init(click_node, text_node, keyboard_type)
	--- 获取Druid实例，用于创建和管理内部组件
	self.druid = self:get_druid()

	--- 初始化文本组件，可以是现有组件或新建组件
	if type(text_node) == "table" then
		--- 如果传入的是文本组件实例，直接使用
		self.text = text_node
	else
		--- 如果传入的是节点名称，创建新的文本组件
		self.text = self.druid:new_text(text_node)
	end

	--- 初始化输入组件的状态变量
	self.is_selected = false                  -- 当前输入字段是否被选中
	self.value = self.text.last_value         -- 当前输入的文本值
	self.previous_value = self.text.last_value -- 上一次的文本值
	self.current_value = self.text.last_value -- 当前正在处理的文本值
	self.marked_value = ""                    -- 标记文本（用于拼音输入等复杂输入法）
	self.is_empty = true                      -- 当前输入是否为空

	--- 初始化文本尺寸相关变量，用于文本布局和显示
	self.text_width = 0                     -- 实际文本宽度
	self.market_text_width = 0              -- 标记文本宽度
	self.total_width = 0                    -- 总宽度
	self.cursor_index = utf8.len(self.value) -- 光标位置（字符索引）
	self.start_index = self.cursor_index
	self.end_index = self.cursor_index

	self.max_length = nil
	self.allowed_characters = nil

	self.keyboard_type = keyboard_type or gui.KEYBOARD_TYPE_DEFAULT

	self.button = self.druid:new_button(click_node, self.select)
	self.button.on_click_outside:subscribe(self.unselect)
	self.button.on_long_click:subscribe(clear_and_select)
	self.button:set_style(nil)

	if defos then
		self.button.hover.style.ON_HOVER_CURSOR = defos.CURSOR_IBEAM
		self.button.hover.style.ON_MOUSE_HOVER_CURSOR = defos.CURSOR_IBEAM
	end

	if html5 then
		self.button:set_web_user_interaction(true)
	end

	self.on_input_select = event.create()
	self.on_input_unselect = event.create()
	self.on_input_text = event.create()
	self.on_input_empty = event.create()
	self.on_input_full = event.create()
	self.on_input_wrong = event.create()
	self.on_select_cursor_change = event.create()
end

---@private
---@param style druid.input.style
function M:on_style_change(style)
	self.style = {
		IS_LONGTAP_ERASE = style.IS_LONGTAP_ERASE or false,
		MASK_DEFAULT_CHAR = style.MASK_DEFAULT_CHAR or "*",
		IS_UNSELECT_ON_RESELECT = style.IS_UNSELECT_ON_RESELECT or false,

		on_init = style.on_init or function() end,
		on_select = style.on_select or function(_, button_node) end,
		on_unselect = style.on_unselect or function(_, button_node) end,
		on_input_wrong = style.on_input_wrong or function(_, button_node) end,
	}

	self.style.on_init(self)
end

---@private
---@param action_id hash|nil 动作ID
---@param action action 动作表
---@return boolean is_consume 如果动作被消耗则返回true
function M:on_input(action_id, action)
	if action_id and not M.ALLOWED_ACTIONS[action_id] then
		-- We want to block all key actions (key_w, key_s) etc while input is selected
		local is_key_action = action.x == nil
		return self.is_selected and is_key_action
	end

	if self.is_selected then
		local input_text = nil
		local is_marked_text_changed = false
		local cursor_shift_indexes = nil

		if action_id == const.ACTION_TEXT then
			-- ignore return key
			if action.text == "\n" or action.text == "\r" then
				return true
			end

			local hex = string.gsub(action.text, "(.)", function(c)
				return string.format("%02X%s", string.byte(c), "")
			end)

			-- ignore arrow keys
			if not utf8.match(hex, "EF9C8[0-3]") then
				if not self.allowed_characters or utf8.match(action.text, self.allowed_characters) then
					local shift_offset = self.cursor_index - self.start_index
					input_text = self:get_text_selected_replaced(action.text)
					cursor_shift_indexes = utf8.len(action.text) - shift_offset
				else
					self.on_input_wrong:trigger(self:get_context(), action.text)
					self.style.on_input_wrong(self, self.button.node)
				end
				self.marked_value = ""
			end
		end

		if action_id == const.ACTION_MARKED_TEXT then
			self.marked_value = action.text or ""
			if self.max_length then
				self.marked_value = utf8.sub(self.marked_value, 1, self.max_length)
			end
			is_marked_text_changed = self.marked_value ~= ""
		end

		if action_id == const.ACTION_BACKSPACE and (action.pressed or action.repeated) then
			local start_index = self.start_index or utf8.len(self.value)
			local end_index = self.end_index or utf8.len(self.value)

			-- If start == end index, remove left of this selection letter, else delete all selection
			if start_index == end_index then
				local left_part = utf8.sub(self.value, 1, math.max(0, start_index - 1))
				local right_part = utf8.sub(self.value, end_index + 1, utf8.len(self.value))
				input_text = left_part .. right_part

				cursor_shift_indexes = -1
			else
				local left_part = utf8.sub(self.value, 1, start_index)
				local right_part = utf8.sub(self.value, end_index + 1, utf8.len(self.value))
				input_text = left_part .. right_part

				-- Calculate offsets from cursor pos to start index
				cursor_shift_indexes = start_index - self.cursor_index
			end
		end

		if action_id == const.ACTION_ENTER and action.released then
			self:unselect()
			return true
		end

		if action_id == const.ACTION_BACK and action.released then
			self:unselect()
			return true
		end

		if action_id == const.ACTION_ESC and action.released then
			self:unselect()
			return true
		end

		if input_text or is_marked_text_changed then
			self:set_text(input_text or self.value)

			if cursor_shift_indexes then
				self:select_cursor(self.cursor_index + cursor_shift_indexes)
			end

			return true
		end
	end

	local is_mouse_action = action_id == const.ACTION_TOUCH or not action_id
	if is_mouse_action then
		return false
	end

	return self.is_selected
end

---@private
function M:on_focus_lost()
	self:unselect()
end

function M:get_text_selected()
	if self.start_index == self.end_index then
		return self.value
	end

	return utf8.sub(self.value, self.start_index + 1, self.end_index)
end

---用新文本替换选中的文本
---@param text string 用于替换选中文本的文本
---@return string new_text 新的输入文本
function M:get_text_selected_replaced(text)
	local left_part = utf8.sub(self.value, 1, self.start_index)
	local right_part = utf8.sub(self.value, self.end_index + 1, utf8.len(self.value))
	local result = left_part .. text .. right_part


	if self.max_length then
		result = utf8.sub(result, 1, self.max_length)
	end

	return result
end

---设置输入字段文本
---@param input_text string? 要应用于输入字段的字符串，如果为nil - 将设置为空字符串
function M:set_text(input_text)
	input_text = tostring(input_text or "")

	-- Case when update with marked text
	if input_text then
		self.value = input_text
	end

	-- Only update the text if it has changed
	local current_value = self.value .. self.marked_value

	if current_value ~= self.current_value then
		self.current_value = current_value

		-- mask text if password field
		local masked_value, masked_marked_value
		if self.keyboard_type == gui.KEYBOARD_TYPE_PASSWORD then
			local mask_char = self.style.MASK_DEFAULT_CHAR or "*"
			masked_value = mask_text(self.value, mask_char)
			masked_marked_value = mask_text(self.marked_value, mask_char)
		end

		-- text + marked text
		local value = masked_value or self.value
		local marked_value = masked_marked_value or self.marked_value
		self.is_empty = #value == 0 and #marked_value == 0

		local final_text = value .. marked_value
		self.text:set_text(final_text)

		-- measure it
		self.text_width = self.text:get_text_size(value)
		self.marked_text_width = self.text:get_text_size(marked_value)
		self.total_width = self.text_width + self.marked_text_width

		self.on_input_text:trigger(self:get_context(), final_text)
		if #final_text == 0 then
			self.on_input_empty:trigger(self:get_context(), final_text)
		end
		if self.max_length and #final_text == self.max_length then
			self.on_input_full:trigger(self:get_context(), final_text)
		end
	end
end

---选择输入字段。它将显示键盘并触发on_select事件
function M:select()
	gui.reset_keyboard()
	self.marked_value = ""
	if not self.is_selected then
		self:set_input_priority(const.PRIORITY_INPUT_MAX, true)
		self.button:set_input_priority(const.PRIORITY_INPUT_MAX, true)
		self.button.hover:set_enabled(false)
		self.previous_value = self.value
		self.is_selected = true

		gui.show_keyboard(self.keyboard_type, false)

		local len = utf8.len(self.value)
		self:select_cursor(len, len, len)
		self.on_input_select:trigger(self:get_context(), self)
		self.style.on_select(self, self.button.node)
	else
		if self.style.IS_UNSELECT_ON_RESELECT then
			self:unselect()
		end
	end
end

---从输入中移除选择。它将隐藏键盘并触发on_unselect事件
function M:unselect()
	gui.reset_keyboard()
	self.marked_value = ""
	self.value = self.current_value
	if self.is_selected then
		self:reset_input_priority()
		self.button:reset_input_priority()
		self.button.hover:set_enabled(true)
		self.is_selected = false

		gui.hide_keyboard()
		self.on_input_unselect:trigger(self:get_context(), self:get_text(), self)

		self.style.on_unselect(self, self.button.node)
	end
end

---返回当前输入字段文本
---@return string text 当前输入字段文本
function M:get_text()
	if self.marked_value ~= "" then
		return self.value .. self.marked_value
	end

	return self.value
end

---设置输入字段的最大长度。
---传递nil使输入字段无限制（默认情况下）
---@param max_length number 输入文本字段的最大长度
---@return druid.input self 当前输入实例
function M:set_max_length(max_length)
	self.max_length = max_length
	return self
end

---设置输入字段允许的字符。
---参考：https://defold.com/ref/stable/string/
---示例：[%a%d] 用于字母和数字
---示例：[abcdef] 只允许这些字符
---示例：[^%s] 只允许非空格字符
---@param characters string 用于验证用户输入的正则表达式
---@return druid.input self 当前输入实例
function M:set_allowed_characters(characters)
	self.allowed_characters = characters
	return self
end

---重置当前输入选择并返回之前的值
---@return druid.input self 当前输入实例
function M:reset_changes()
	self:set_text(self.previous_value)
	self:unselect()
	return self
end

---设置输入字段中的光标位置
---@param cursor_index number|nil 光标位置的光标索引，如果为nil - 将设置为文本末尾
---@param start_index number|nil 光标位置的起始索引，如果为nil - 将设置为文本末尾
---@param end_index number|nil 光标位置的结束索引，如果为nil - 将设置为start_index
---@return druid.input self 当前输入实例
function M:select_cursor(cursor_index, start_index, end_index)
	local len = utf8.len(self.value)

	self.cursor_index = cursor_index or len
	self.start_index = start_index or self.cursor_index
	self.end_index = end_index or self.start_index

	self.cursor_index = helper.clamp(self.cursor_index, 0, len)
	self.start_index = helper.clamp(self.start_index, 0, len)
	self.end_index = helper.clamp(self.end_index, 0, len)

	self.on_select_cursor_change:trigger(self:get_context(), self.cursor_index, self.start_index, self.end_index)

	return self
end

---按增量更改光标位置
---@param delta number 光标位置的方向，-1表示向左，1表示向右
---@param is_add_to_selection boolean （Shift键）
---@param is_move_to_end boolean （Ctrl键）
---@return druid.input self 当前输入实例
function M:move_selection(delta, is_add_to_selection, is_move_to_end)
	local len = utf8.len(self.value)
	local cursor_index = self.cursor_index
	local start_index, end_index -- if nil, the selection will be 0 at cursor position
	local is_right = delta > 0

	local target_index = cursor_index + delta
	if is_move_to_end then
		target_index = is_right and len or 0
	end

	-- The Shift is not pressed
	if not is_add_to_selection then
		cursor_index = target_index

		if self.start_index ~= self.end_index then
			-- Reset selection without moving cursor
			cursor_index = self.cursor_index
		end
	end

	-- The Shift is pressed
	if is_add_to_selection then
		cursor_index = target_index
		start_index = self.start_index
		end_index = self.end_index

		local is_cursor_extends_selection = (self.cursor_index == (is_right and end_index or start_index))

		if is_cursor_extends_selection then
			if is_right then
				end_index = cursor_index
			else
				start_index = cursor_index
			end
		else
			if is_right then
				start_index = cursor_index

				if is_move_to_end then
					start_index = end_index
					end_index = cursor_index
				end
			else
				end_index = cursor_index

				if is_move_to_end then
					end_index = start_index
					start_index = cursor_index
				end
			end
		end
	end

	self:select_cursor(cursor_index, start_index, end_index)

	return self
end

return M
