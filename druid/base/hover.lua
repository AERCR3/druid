local event = require("event.event")
local const = require("druid.const")
local helper = require("druid.helper")
local component = require("druid.component")

---@class druid.hover.style
---@field ON_HOVER_CURSOR string|number|nil 节点悬停时的鼠标悬停样式
---@field ON_MOUSE_HOVER_CURSOR string|number|nil 节点鼠标悬停时的鼠标悬停样式

---用于处理节点上的悬停事件的组件
---悬停组件用于检测鼠标或触摸在UI元素上的悬停状态，常用于提供视觉反馈
---@class druid.hover: druid.component
---@field node node GUI节点
---@field on_hover event fun(self: druid.hover, is_hover: boolean) 悬停事件
---@field on_mouse_hover event fun(self: druid.hover, is_hover: boolean) 鼠标悬停事件
---@field style druid.hover.style 悬停组件的样式
---@field click_zone node 悬停组件的点击区域
---@field private _is_hovered boolean|nil 如果节点被悬停则为真
---@field private _is_mouse_hovered boolean|nil 如果节点被鼠标悬停则为真
---@field private _is_enabled boolean|nil 如果悬停组件已启用则为真
---@field private _is_mobile boolean 如果平台是移动设备则为真
local M = component.create("hover")


---悬停组件的构造函数
---初始化悬停组件实例，设置GUI节点和悬停事件回调
---此组件用于检测和响应鼠标/触摸在UI元素上的悬停状态
---@param node node GUI场景中的节点名称或节点对象
--- 用于检测悬停状态的UI元素
---@param on_hover_callback function 普通悬停回调函数
--- 当触摸/鼠标悬停状态改变时调用，参数为悬停状态（boolean）
---@param on_mouse_hover function 鼠标悬停回调函数
--- 当鼠标悬停状态改变时调用，参数为悬停状态（boolean）
function M:init(node, on_hover_callback, on_mouse_hover)
	--- 获取GUI节点对象
	self.node = self:get_node(node)

	--- 初始化悬停状态变量
	self._is_hovered = false            -- 当前是否处于触摸悬停状态
	self._is_mouse_hovered = false      -- 当前是否处于鼠标悬停状态
	self._is_enabled = true             -- 悬停组件是否启用
	self._is_mobile = helper.is_mobile() -- 检测是否为移动设备

	--- 创建悬停事件，用于通知其他组件悬停状态变化
	self.on_hover = event.create(on_hover_callback)   -- 触摸悬停事件
	self.on_mouse_hover = event.create(on_mouse_hover) -- 鼠标悬停事件
end

---私有方法：后期初始化
---在组件完全初始化后调用此方法，设置点击区域和执行其他初始化操作
---与按钮组件类似，如果没有设置点击区域，会自动查找最近的遮罩节点
---@private
function M:on_late_init()
	--- 检查是否设置了自定义点击区域
	--- 如果没有设置，则自动查找最近的遮罩节点作为点击区域
	--- 这确保了悬停检测在遮罩容器中能正确工作
	if not self.click_zone then
		--- 获取悬停节点最近的遮罩节点
		local stencil_node = helper.get_closest_stencil_node(self.node)
		--- 如果找到遮罩节点，则将其设置为悬停检测区域
		if stencil_node then
			self:set_click_zone(stencil_node)
		end
	end
end

---私有方法：处理悬停组件样式变化
---当悬停组件的样式配置发生改变时调用此方法，更新样式参数
---@private
---@param style druid.hover.style 新的样式配置表
--- 包含悬停相关的样式设置
function M:on_style_change(style)
	--- 合并用户自定义样式与默认样式
	self.style = {}
	--- 普通悬停时的鼠标指针样式
	--- 可以是字符串（如"hand"）或数值，设置为nil则使用默认样式
	self.style.ON_HOVER_CURSOR = style.ON_HOVER_CURSOR or nil
	--- 鼠标悬停时的鼠标指针样式
	--- 可以是字符串（如"text"）或数值，设置为nil则使用默认样式
	self.style.ON_MOUSE_HOVER_CURSOR = style.ON_MOUSE_HOVER_CURSOR or nil
end

---私有方法：处理输入事件
---这是悬停组件的核心事件处理函数，负责检测和响应各种悬停状态变化
---支持触摸悬停、鼠标悬停和移动设备的不同交互模式
---@private
---@param action_id hash 输入动作的哈希ID
---@param action table 输入动作的详细数据，包含位置、状态等信息
---@return boolean is_consumed 是否消耗此输入事件
--- 悬停组件通常不消耗输入事件，返回false
function M:on_input(action_id, action)
	--- 检查输入类型是否匹配悬停组件支持的事件
	--- 只处理触摸事件、空动作（鼠标悬停）和nil动作
	if action_id ~= const.ACTION_TOUCH and action_id ~= nil then
		return false
	end

	--- 移动设备上禁用鼠标悬停检测
	--- 移动设备只处理触摸事件，不处理鼠标悬停
	if self._is_mobile and not action_id then
		return false
	end

	--- 检查悬停组件和GUI节点是否启用
	--- 如果禁用，则清除所有悬停状态
	if not gui.is_enabled(self.node, true) or not self._is_enabled then
		self:set_hover(false)     -- 清除触摸悬停状态
		self:set_mouse_hover(false) -- 清除鼠标悬停状态
		return false
	end

	--- 检测输入位置是否在悬停区域内
	--- click_zone用于精确控制悬停检测范围，特别是在遮罩或滚动容器中
	local is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)

	--- 根据输入类型选择相应的悬停处理函数
	--- 有action_id时为触摸事件，使用set_hover
	--- 无action_id时为鼠标事件，使用set_mouse_hover
	local hover_function = action_id and self.set_hover or self.set_mouse_hover

	--- 如果输入不在悬停区域内，清除悬停状态
	if not is_pick then
		hover_function(self, false)
		return false
	end

	--- 根据输入状态设置悬停效果
	--- 触摸释放时清除悬停状态，其他情况设置悬停状态
	if action.released then
		hover_function(self, false) -- 释放时取消悬停
	else
		hover_function(self, true) -- 按下/悬停时启用悬停效果
	end

	--- 悬停组件不消耗输入事件，允许其他组件也处理
	return false
end

---私有方法：处理输入中断事件
---当输入事件被其他组件消耗或中断时调用此方法
---用于清理悬停状态，防止状态不一致
---@private
function M:on_input_interrupt()
	--- 清除所有悬停状态，防止状态残留
	self:set_hover(false) -- 清除触摸悬停状态
end

---设置触摸悬停状态
---此方法手动控制悬停组件的触摸悬停状态，可以强制启用或禁用悬停效果
---当悬停状态改变时，会触发相应的事件回调和鼠标指针变化
---@param state boolean|nil 悬停状态
--- true表示启用悬停状态，false表示禁用悬停状态
--- nil表示禁用悬停状态（与false效果相同）
function M:set_hover(state)
	--- 如果悬停状态没有改变，直接返回，避免重复触发
	if self._is_hovered == state then
		return
	end

	--- 更新悬停状态
	self._is_hovered = state
	--- 触发悬停事件，通知其他组件悬停状态变化
	self.on_hover:trigger(self:get_context(), state, self)

	--- 如果支持defos窗口系统且有自定义鼠标指针样式，则改变鼠标指针
	if defos and self.style.ON_HOVER_CURSOR then
		--- 参数3表示悬停状态的鼠标指针样式
		--- state为true时使用自定义指针，false时恢复默认指针
		self:_set_cursor(3, state and self.style.ON_HOVER_CURSOR or nil)
	end
end

---获取当前触摸悬停状态
---此方法返回悬停组件当前的触摸悬停状态
---状态取决于是否有触摸动作当前作用于节点
---@return boolean is_hovered 当前的触摸悬停状态
--- true表示有触摸动作在节点上，false表示没有
function M:is_hovered()
	--- 返回内部保存的触摸悬停状态
	return self._is_hovered
end

---设置鼠标悬停状态
---此方法手动控制悬停组件的鼠标悬停状态，主要用于桌面平台的鼠标交互
---当鼠标悬停状态改变时，会触发相应的事件回调和鼠标指针变化
---@param state boolean|nil 鼠标悬停状态
--- true表示启用鼠标悬停状态，false表示禁用鼠标悬停状态
--- nil表示禁用鼠标悬停状态（与false效果相同）
function M:set_mouse_hover(state)
	--- 如果鼠标悬停状态没有改变，直接返回，避免重复触发
	if self._is_mouse_hovered == state then
		return
	end

	--- 更新鼠标悬停状态
	self._is_mouse_hovered = state
	--- 触发鼠标悬停事件，通知其他组件鼠标悬停状态变化
	self.on_mouse_hover:trigger(self:get_context(), state, self)

	--- 如果支持defos窗口系统且有自定义鼠标指针样式，则改变鼠标指针
	if defos and self.style.ON_MOUSE_HOVER_CURSOR then
		--- 参数2表示鼠标悬停状态的鼠标指针样式
		--- state为true时使用自定义指针，false时恢复默认指针
		self:_set_cursor(2, state and self.style.ON_MOUSE_HOVER_CURSOR or nil)
	end
end

---获取当前鼠标悬停状态
---此方法返回悬停组件当前的鼠标悬停状态
---状态取决于是否有nil action_id（通常是桌面鼠标）当前作用于节点
---@return boolean 当前的鼠标悬停状态
--- true表示有鼠标在节点上悬停，false表示没有
function M:is_mouse_hovered()
	--- 返回内部保存的鼠标悬停状态
	return self._is_mouse_hovered
end

---设置悬停组件的精确点击区域
---此方法允许精确控制悬停检测的范围，特别适用于复杂UI场景
---例如在遮罩容器、滚动视图或需要限制悬停范围的组件中
---@param zone node|string|nil 指定悬停检测区域的GUI节点
--- 可以是节点对象、节点名称字符串
--- 如果为nil，则清除自定义悬停区域设置，使用默认节点区域
function M:set_click_zone(zone)
	--- 如果没有提供区域节点，则清除自定义悬停区域
	--- 此时悬停检测将使用节点本身的边界
	if not zone then
		self.click_zone = nil
		return
	end

	--- 获取节点对象并设置为悬停检测区域
	self.click_zone = self:get_node(zone)
end

---设置悬停组件的启用状态
---此方法可以启用或禁用整个悬停组件的功能
---当禁用时，组件不会检测任何悬停事件，也不会触发回调
---@param state boolean|nil 悬停组件的启用状态
--- true表示启用悬停检测，false表示禁用悬停检测
--- nil表示禁用悬停检测（与false效果相同）
function M:set_enabled(state)
	--- 设置启用状态标志
	self._is_enabled = state

	--- 如果禁用了悬停组件，需要清除所有当前的悬停状态
	--- 防止组件处于禁用状态时仍然保持悬停效果
	if not state then
		--- 清除触摸悬停状态
		if self._is_hovered then
			self:set_hover(false)
		end
		--- 清除鼠标悬停状态
		if self._is_mouse_hovered then
			self:set_mouse_hover(false)
		end
	end
end

---返回当前悬停启用状态
---@return boolean 悬停启用状态
function M:is_enabled()
	return self._is_enabled
end

---内部光标堆栈
local cursor_stack = {}
---@local
---设置光标
---@param number 优先级
---@param cursor 光标类型
function M:_set_cursor(priority, cursor)
	if not defos then
		return
	end

	local uid = self:get_uid()
	cursor_stack[uid] = cursor_stack[uid] or {}
	cursor_stack[uid][priority] = cursor

	-- 通过pairs按高优先级设置光标
	local priority = nil
	local cursor_to_set = nil
	for _, stack in pairs(cursor_stack) do
		for pr, _ in pairs(stack) do
			if pr > (priority or 0) then
				priority = pr
				cursor_to_set = stack[priority]
			end
		end
	end

	defos.set_cursor(cursor_to_set)
end

return M
