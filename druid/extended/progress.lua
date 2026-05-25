local event = require("event.event")
local helper = require("druid.helper")
local component = require("druid.component")

---@class druid.progress.style
---@field SPEED number|nil 进度条填充速率。更高的值意味着更快的填充。默认值: 5
---@field MIN_DELTA number|nil 进度条的最小步长。默认值: 0.005

---基本的Druid进度条组件。通过更改节点的大小或缩放来表示进度。
---
---### 设置
---使用druid创建进度条组件: `progress = druid:new_progress(node_name, key, init_value)`
---
---### 注意事项
---- 节点在GUI场景中应具有最大节点大小，它代表进度条的最大大小
---- 键是来自druid常量的值："x"或"y"
---- 进度条与9切片节点配合良好，它首先尝试通过_set_size_设置大小直到达到最小大小，然后通过_set_scale_继续调整大小
---- 进度条只能按垂直或水平大小填充。对于对角线进度条，只需在GUI场景中旋转节点
---- 如果进度条出现闪烁或纹理暗斑问题，请尝试在纹理配置文件中禁用mipmaps
---进度条组件用于可视化显示任务完成进度或资源状态
---@class druid.progress: druid.component
---@field node node 进度条节点
---@field on_change event fun(self: druid.progress, value: number) 进度值改变时触发的事件
---@field style druid.progress.style 组件样式参数
---@field key string 进度条方向："x"或"y"
---@field prop hash 用于缩放进度条的属性
local M = component.create("progress")


---进度条构造函数
---初始化进度条组件，设置节点、方向和初始值
---@param node string|node 节点名称或GUI节点本身
---@param key string 进度条方向："x"或"y"
---@param init_value number|nil 进度条的初始值（0到1）。默认值: 1
function M:init(node, key, init_value)
	assert(key == "x" or key == "y", "Progress bar key should be 'x' or 'y'")

	self.key = key
	self.prop = hash("scale." .. self.key)

	self._init_value = init_value or 1
	self.node = self:get_node(node)
	self.scale = gui.get_scale(self.node)
	self.size = gui.get_size(self.node)
	self.max_size = gui.get_size(self.node)
	self.slice = gui.get_slice9(self.node)
	self.last_value = self._init_value

	self.slice_size = vmath.vector3(
		self.slice.x + self.slice.z,
		self.slice.y + self.slice.w,
		0
	)

	self.on_change = event.create()

	self:set_to(self.last_value)
end

---内部方法：处理样式变化
---当进度条组件样式发生变化时调用此私有方法
---@private
---@param style druid.progress.style 样式配置
function M:on_style_change(style)
	self.style = {
		SPEED = style.SPEED or 5,
		MIN_DELTA = style.MIN_DELTA or 0.005,
	}
end

---@private
function M:on_layout_change()
	self:set_to(self.last_value)
end

---@private
function M:on_remove()
	gui.set_size(self.node, self.max_size)
end

---@param dt number Delta time
function M:update(dt)
	if self.target then
		local prev_value = self.last_value
		local step = math.abs(self.last_value - self.target) * (self.style.SPEED * dt)
		step = math.max(step, self.style.MIN_DELTA)
		self:set_to(helper.step(self.last_value, self.target, step))

		if self.last_value == self.target then
			self:_check_steps(prev_value, self.target, self.target)

			if self.target_callback then
				self.target_callback(self:get_context(), self.target)
			end

			self.target = nil
		end
	end
end

---Fill the progress bar
---@return druid.progress self Current progress instance
function M:fill()
	self:_set_bar_to(1, true)

	return self
end

---Empty the progress bar
---@return druid.progress self Current progress instance
function M:empty()
	self:_set_bar_to(0, true)

	return self
end

---Instant fill progress bar to value
---@param to number Progress bar value, from 0 to 1
---@return druid.progress self Current progress instance
function M:set_to(to)
	to = helper.clamp(to, 0, 1)
	self:_set_bar_to(to)

	return self
end

---Return the current value of the progress bar
---@return number value The current value of the progress bar
function M:get()
	return self.last_value
end

---Set points on progress bar to fire the callback
---@param steps number[] Array of progress bar values
---@param callback function Callback on intersect step value
---@return druid.progress self Current progress instance
function M:set_steps(steps, callback)
	self.steps = steps
	self.step_callback = callback

	return self
end

---Start animation of a progress bar
---@param to number value between 0..1
---@param callback function|nil Callback on animation ends
---@return druid.progress self Current progress instance
function M:to(to, callback)
	to = helper.clamp(to, 0, 1)
	-- cause of float error
	local value = helper.round(to, 5)
	if value ~= self.last_value then
		self.target = value
		self.target_callback = callback
	else
		if callback then
			callback(self:get_context(), to)
		end
	end

	return self
end

---Set progress bar max node size
---@param max_size vector3 The new node maximum (full) size
---@return druid.progress self Current progress instance
function M:set_max_size(max_size)
	self.max_size[self.key] = max_size[self.key]
	self:set_to(self.last_value)

	return self
end

---@private
---@param from number The start value
---@param to number The end value
---@param exactly number|nil The exact value
function M:_check_steps(from, to, exactly)
	if not self.steps then
		return
	end

	for i = 1, #self.steps do
		local step = self.steps[i]
		local v1, v2 = from, to
		if v1 > v2 then
			v1, v2 = v2, v1
		end

		if v1 < step and step < v2 then
			self.step_callback(self:get_context(), step)
		end
		if exactly and exactly == step then
			self.step_callback(self:get_context(), step)
		end
	end
end

---@private
---@param set_to number The value to set the progress bar to
function M:_set_bar_to(set_to, is_silent)
	local prev_value = self.last_value
	local other_side = self.key == "x" and "y" or "x"
	self.last_value = set_to

	local total_width = set_to * self.max_size[self.key]

	local scale = 1
	if self.slice_size[self.key] > 0 then
		scale = math.min(total_width / self.slice_size[self.key], 1)
	end
	local size = math.max(total_width, self.slice_size[self.key])

	do -- Scale other side
		-- Decrease other side of progress bar to match the oppotize slice_size
		local minimal_size = self.size[other_side] - self.slice_size[other_side]
		local maximum_size = self.size[other_side]
		local scale_diff = (maximum_size - minimal_size) / maximum_size
		local other_scale = 1 - (scale_diff * (1 - scale))
		self.scale[other_side] = other_scale
	end

	self.scale[self.key] = scale
	gui.set_scale(self.node, self.scale)

	self.size[self.key] = size
	gui.set_size(self.node, self.size)

	if not is_silent then
		self:_check_steps(prev_value, set_to)
		if prev_value ~= self.last_value then
			self.on_change:trigger(self:get_context(), self.last_value)
		end
	end

	return self
end

return M
