local event = require("event.event")
local const = require("druid.const")
local helper = require("druid.helper")
local component = require("druid.component")

---@class druid.swipe.style
---@field SWIPE_TIME number|nil 触发滑动的最大时间。默认值: 0.4
---@field SWIPE_THRESHOLD number|nil 触发滑动的最小距离。默认值: 50
---@field SWIPE_TRIGGER_ON_MOVE boolean|nil 如果为真，则在滑动移动时触发，而不仅仅是在释放操作时。默认值: false

---用于管理节点上的滑动手势事件的组件
---滑动组件用于检测用户在UI元素上的滑动手势，常用于页面切换或菜单操作
---@class druid.swipe: druid.component
---@field node node 管理滑动的节点
---@field on_swipe event fun(context, side, dist, dt) 检测到滑动时触发的事件
---@field style druid.swipe.style 滑动的样式
---@field click_zone node 滑动的点击区域
---@field private _trigger_on_move boolean 如果滑动应在移动时触发则为真
---@field private _swipe_start_time number 滑动开始的时间
---@field private _start_pos vector3 滑动的起始位置
---@field private _is_enabled boolean 如果滑动已启用则为真
---@field private _is_mobile boolean 如果滑动在移动设备上则为真
local M = component.create("swipe")


---滑动组件构造函数
---初始化滑动组件，设置管理滑动的节点和滑动回调函数
---@param node_or_node_id node|string 节点或节点ID
---@param on_swipe_callback function 滑动回调函数
function M:init(node_or_node_id, on_swipe_callback)
	self._trigger_on_move = self.style.SWIPE_TRIGGER_ON_MOVE
	self.node = self:get_node(node_or_node_id)

	self._swipe_start_time = 0
	self._start_pos = vmath.vector3(0)

	self.click_zone = nil
	self.on_swipe = event.create(on_swipe_callback)
end

---@private
function M:on_late_init()
	if not self.click_zone then
		local stencil_node = helper.get_closest_stencil_node(self.node)
		if stencil_node then
			self:set_click_zone(stencil_node)
		end
	end
end

---内部方法：处理样式变化
---当滑动组件样式发生变化时调用此私有方法
---@private
---@param style druid.swipe.style 滑动样式
function M:on_style_change(style)
	self.style = {
		SWIPE_TIME = style.SWIPE_TIME or 0.4,
		SWIPE_THRESHOLD = style.SWIPE_THRESHOLD or 50,
		SWIPE_TRIGGER_ON_MOVE = style.SWIPE_TRIGGER_ON_MOVE or false,
	}
end

---内部方法：处理输入事件
---此函数处理滑动组件的输入事件，检测滑动手势
---@private
---@param action_id hash 动作ID
---@param action action 动作表
---@return boolean is_consumed 如果输入被消耗则为真
function M:on_input(action_id, action)
	if action_id ~= const.ACTION_TOUCH then
		return false
	end

	if not gui.is_enabled(self.node, true) then
		return false
	end

	local is_pick = helper.pick_node(self.node, action.x, action.y, self.click_zone)
	if not is_pick then
		self:_reset_swipe()
		return false
	end

	if self._swipe_start_time ~= 0 and (self._trigger_on_move or action.released) then
		self:_check_swipe(action)
	end

	if action.pressed then
		self:_start_swipe(action)
	end

	if action.released then
		self:_reset_swipe()
	end

	return true
end

---@private
function M:on_input_interrupt()
	self:_reset_swipe()
end

---Set the click zone for the swipe, useful for restricting events outside stencil node
---@param zone node|string|nil Gui node
function M:set_click_zone(zone)
	if not zone then
		self.click_zone = nil
		return
	end

	self.click_zone = self:get_node(zone)
end

---Start swipe event
---@param action action The action table
function M:_start_swipe(action)
	self._swipe_start_time = socket.gettime()
	self._start_pos.x = action.x
	self._start_pos.y = action.y
end

---Reset swipe event
function M:_reset_swipe()
	self._swipe_start_time = 0
end

---Check swipe event
---@param self druid.swipe
---@param action action
function M:_check_swipe(action)
	local dx = action.x - self._start_pos.x
	local dy = action.y - self._start_pos.y
	local dist = helper.distance(self._start_pos.x, self._start_pos.y, action.x, action.y)
	local delta_time = socket.gettime() - self._swipe_start_time
	local is_swipe = self.style.SWIPE_THRESHOLD <= dist and delta_time <= self.style.SWIPE_TIME

	if is_swipe then
		local is_x_swipe = math.abs(dx) >= math.abs(dy)
		local swipe_side = "undefined"

		if is_x_swipe and dx > 0 then
			swipe_side = "right"
		end
		if is_x_swipe and dx < 0 then
			swipe_side = "left"
		end
		if not is_x_swipe and dy > 0 then
			swipe_side = "up"
		end
		if not is_x_swipe and dy < 0 then
			swipe_side = "down"
		end

		self.on_swipe:trigger(self:get_context(), swipe_side, dist, delta_time)
		self:_reset_swipe()
	end
end

return M
