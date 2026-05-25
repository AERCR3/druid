local event = require("event.event")
local helper = require("druid.helper")
local component = require("druid.component")

---@class druid.hotkey.style
---@field MODIFICATORS string[]|hash[] 作为热键修饰符的action_id列表

---Druid组件，用于管理热键并在按下热键时触发回调。
---
---### 设置
---使用druid创建热键组件: `hotkey = druid:new_hotkey(keys, callback, callback_argument)`
---
---### 注意事项
---- 热键可以通过单个按键或组合键触发
---- 热键支持修饰键（例如Ctrl、Shift、Alt）
---- 热键可以在按键按下、释放或重复时触发
---- 热键可以在运行时添加或删除
---- 热键可以启用或禁用
---- 热键可以设置为按键持续时重复触发
---热键组件用于处理键盘快捷键，支持修饰键组合
---@class druid.hotkey: druid.component
---@field on_hotkey_pressed event fun(self, context, callback_argument) 按下热键时触发的事件
---@field on_hotkey_released event fun(self, context, callback_argument) 释放热键时触发的事件
---@field style druid.hotkey.style 热键组件的样式
---@field private _hotkeys table 热键列表
---@field private _modificators table 修饰符列表
---@field private _node node|nil 绑定热键的节点
local M = component.create("hotkey")


---热键构造函数
---初始化热键组件，设置要按下的键和回调函数
---@param keys string[]|string 触发回调要按下的键。应包含一个主键和任意修饰键
---@param callback function 回调函数
---@param callback_argument any|nil 传递给回调函数的参数
function M:init(keys, callback, callback_argument)
	self.druid = self:get_druid()

	self._hotkeys = {}
	self._modificators = {}
	self._node = nil
	self.on_hotkey_pressed = event.create()
	self.on_hotkey_released = event.create(callback)

	if keys then
		self:add_hotkey(keys, callback_argument)
	end
end

---内部方法：处理样式变化
---当热键组件样式发生变化时调用此私有方法
---@private
---@param style druid.hotkey.style 热键样式
function M:on_style_change(style)
	self.style = {
		MODIFICATORS = style.MODIFICATORS or {},
	}

	for index = 1, #style.MODIFICATORS do
		local modificator = style.MODIFICATORS[index]
		if type(modificator) == "string" then
			self.style.MODIFICATORS[index] = hash(modificator)
		end
	end
end

---为组件回调添加热键
---此函数允许在运行时动态添加新的热键绑定
---@param keys string[]|hash[]|string|hash 激活前必须按下的键
---@param callback_argument any|nil 传递给回调函数的参数
---@return druid.hotkey self 当前实例
function M:add_hotkey(keys, callback_argument)
	keys = keys or {}
	if type(keys) == "string" then
		keys = { keys }
	end

	local modificators = {}
	local key = nil

	---@cast keys string[]
	for index = 1, #keys do
		local key_hash = hash(keys[index])
		if #keys > 1 and helper.contains(self.style.MODIFICATORS, key_hash) then
			table.insert(modificators, key_hash)
		else
			if not key then
				key = key_hash
			else
				error("The hotkey keys should contains only one key (except modificator keys)")
			end
		end
	end

	table.insert(self._hotkeys, {
		modificators = modificators,
		key = key,
		is_processing = false,
		callback_argument = callback_argument,
	})

	-- Current hotkey status
	local mods = self.style.MODIFICATORS ---@type string[]
	for index = 1, #mods do
		local modificator = hash(mods[index])
		self._modificators[modificator] = self._modificators[modificator] or false
	end

	return self
end

function M:is_processing()
	for index = 1, #self._hotkeys do
		if self._hotkeys[index].is_processing then
			return true
		end
	end

	return false
end

---@private
function M:on_focus_gained()
	for k, v in pairs(self._modificators) do
		self._modificators[k] = false
	end
end

---@private
---@param action_id hash|nil The action id
---@param action action The action
---@return boolean is_consume True if the action is consumed
function M:on_input(action_id, action)
	if not action_id then
		return false
	end

	if self._node and not gui.is_enabled(self._node, true) then
		return false
	end

	if self._modificators[action_id] ~= nil and action.pressed then
		self._modificators[action_id] = true
	end

	for index = 1, #self._hotkeys do
		local hotkey = self._hotkeys[index]
		local is_relative_key = helper.contains(self.style.MODIFICATORS, action_id) or action_id == hotkey.key

		if is_relative_key and (action_id == hotkey.key or not hotkey.key) then
			local is_modificator_ok = true
			local is_consume = not not (hotkey.key)

			-- Check only required modificators pressed
			if hotkey.key and #hotkey.modificators > 0 then
				for i = 1, #self.style.MODIFICATORS do
					local mod = self.style.MODIFICATORS[i]
					if helper.contains(hotkey.modificators, mod) and self._modificators[mod] == false then
						is_modificator_ok = false
					end
					if not helper.contains(hotkey.modificators, mod) and self._modificators[mod] == true then
						is_modificator_ok = false
					end
				end
			end

			if action.pressed and is_modificator_ok then
				hotkey.is_processing = true
				self.on_hotkey_pressed:trigger(self:get_context(), hotkey.callback_argument)
			end
			if not action.pressed and self._is_process_repeated and action.repeated and is_modificator_ok and hotkey.is_processing then
				self.on_hotkey_released:trigger(self:get_context(), hotkey.callback_argument)
				return is_consume
			end
			if action.released and is_modificator_ok and hotkey.is_processing then
				self.on_hotkey_released:trigger(self:get_context(), hotkey.callback_argument)
				hotkey.is_processing = false
				return is_consume
			end
		end
	end

	if self._modificators[action_id] ~= nil and action.released then
		self._modificators[action_id] = false
	end

	return false
end

---If true, the callback will be triggered on action.repeated
---@param is_enabled_repeated boolean The flag value
---@return druid.hotkey self Current instance
function M:set_repeat(is_enabled_repeated)
	self._is_process_repeated = is_enabled_repeated
	return self
end

---If node is provided, the hotkey can be disabled, if the node is disabled
---@param node node|nil The node to bind the hotkey to. Nil to unbind the node
---@return druid.hotkey self Current instance
function M:bind_node(node)
	self._node = node

	return self
end

return M
