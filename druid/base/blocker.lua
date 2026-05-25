local const = require("druid.const")
local component = require("druid.component")

---用于阻止输入的Druid组件。用于在特殊区域阻止输入。
---
---### 设置
---使用druid创建阻挡器组件: `druid:new_blocker(node_name)`
---
---### 注意事项
---- 阻挡器可用于创建安全区域，例如在大按钮周围
---- 阻挡器将捕获命中节点的所有输入事件，防止它们到达其他组件
---- 阻挡器作为常规组件放置在堆栈中，因此可以将任何其他组件放在其上方并正常工作
---阻挡器组件用于阻止特定区域的输入事件传播，常用于模态对话框或覆盖层
---@class druid.blocker: druid.component
---@field node node 将阻止输入的节点
---@field private _is_enabled boolean 阻挡器是否启用
local M = component.create("blocker")


---阻挡器构造函数
---初始化阻挡器组件，设置用作阻挡器的节点
---@param node node|string 用作阻挡器的节点或节点名称
function M:init(node)
	self.node = self:get_node(node)
	self._is_enabled = true
end

---内部方法：处理输入事件
---此函数处理阻挡器的输入事件，如果输入在阻挡器区域内则消耗该事件
---@private
---@param action_id string 动作ID
---@param action table 动作表
---@return boolean is_consumed 如果输入被消耗则为真
function M:on_input(action_id, action)
	if action_id ~= const.ACTION_TOUCH and
			action_id ~= const.ACTION_MULTITOUCH and
			action_id ~= nil then
		return false
	end

	if not self:is_enabled() then
		return false
	end

	if not gui.is_enabled(self.node, true) then
		return false
	end

	if gui.pick_node(self.node, action.x, action.y) then
		return true
	end

	return false
end

---设置阻挡器启用状态
---此函数允许动态启用或禁用阻挡器，控制其是否拦截输入事件
---@param state boolean 新的启用状态
---@return druid.blocker self 阻挡器实例
function M:set_enabled(state)
	self._is_enabled = state

	return self
end

---获取阻挡器启用状态
---返回阻挡器当前是否处于启用状态
---@return boolean is_enabled 如果阻挡器已启用则为真
function M:is_enabled()
	return self._is_enabled
end

return M
