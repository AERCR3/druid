local event = require("event.event")
local const = require("druid.const")
local component = require("druid.component")

---处理返回按钮的组件。它处理Android返回按钮和退格键。
---
---### 设置
---使用druid创建返回处理器组件: `druid:new_back_handler(callback)`
---
---### 注意事项
---- 应在`input.binding`中设置键触发器以正确工作
---- 它使用key_back和key_backspace动作ID
---返回处理器组件用于处理Android设备的物理返回键和键盘退格键的事件
---@class druid.back_handler: druid.component
---@field on_back event fun(self: druid.back_handler, params: any?) 返回处理器动作触发时调用
---@field params any? 传递给回调的自定义参数
local M = component.create("back_handler")


---返回处理器构造函数
---初始化返回处理器组件，设置触发时的回调函数和自定义参数
---@param callback function|nil 返回处理器触发时调用的回调函数
---@param params any? 传递给回调的自定义参数
function M:init(callback, params)
	self.params = params
	self.on_back = event.create(callback)
end

---内部方法：处理输入事件
---此函数处理返回键和退格键的输入事件
---@private
---@param action_id hash 动作ID
---@param action table 动作表
---@return boolean is_consumed 如果输入被消耗则为真
function M:on_input(action_id, action)
	if action.released and (action_id == const.ACTION_BACK or action_id == const.ACTION_BACKSPACE) then
		self.on_back:trigger(self:get_context(), self.params)
		return true
	end

	return false
end

return M
