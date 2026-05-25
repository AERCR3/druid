local event = require("event.event")
local helper = require("druid.helper")
local component = require("druid.component")


--- Druid性能分析器面板组件：显示内存使用、FPS和组件数量等性能指标
---@class panel_druid_profiler: druid.component
---@field root druid.container
---@field druid druid.instance
local M = component.create("panel_druid_profiler")
-- FPS采样数量（用于计算平均FPS）
local FPS_SAMPLES = 60

--- 初始化函数：创建布局、文本组件和定时更新任务
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加三个分组容器（内存、FPS、组件）
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.group_memory = self.root:add_container("group_memory")
	self.group_fps = self.root:add_container("group_fps")
	self.group_components = self.root:add_container("group_components")

	-- 创建水平布局，将三个分组容器排列在一起
	self.root:add_container("layout", nil, function()
		self.layout:set_dirty()
	end)
	self.layout = self.druid:new_layout("layout", "horizontal")
	self.layout:add(self.group_memory.node)
	self.layout:add(self.group_fps.node)
	self.layout:add(self.group_components.node)
	self.layout:set_justify(true)

	-- 创建垃圾回收按钮，点击时手动触发GC
	self.druid:new_button("group_memory", self.run_collectgarbage)

	-- 设置每个分组的最小宽度
	self.group_memory:set_min_size(270, nil)
	self.group_fps:set_min_size(270, nil)
	self.group_components:set_min_size(270, nil)

	-- 创建显示数值的文本组件
	self.text_memory_amount = self.druid:new_text("text_memory_amount")
	self.text_fps_amount = self.druid:new_text("text_fps_amount")
	self.text_fps_min = self.druid:new_text("text_fps_min")
	self.text_components_amount = self.druid:new_text("text_components_amount")

	-- 创建标签文本（本地化）
	self.druid:new_lang_text("text_memory", "ui_profiler_memory")
	self.druid:new_lang_text("text_fps", "ui_profiler_fps")
	self.druid:new_lang_text("text_components", "ui_profiler_components")

	self.previous_time = nil
	self.fps_samples = {}

	-- 存储各分组的节点引用，用于居中对齐
	self.nodes_memory = {
		self:get_node("text_memory"),
		self:get_node("text_memory_amount"),
		self:get_node("text_memory_kb"),
	}
	self.nodes_fps = {
		self:get_node("text_fps"),
		self:get_node("text_fps_amount"),
		self:get_node("text_fps_min"),
	}
	self.nodes_components = {
		self:get_node("text_components"),
		self:get_node("text_components_amount"),
	}

	-- 每0.16秒更新一次性能数据
	timer.delay(0.16, true, function()
		self:update_memory()
		self:update_fps()
		self:update_components()
		self.layout:set_dirty()
	end)
end

--- 语言切换回调：重新更新所有性能数据显示
function M:on_language_change()
	self:update_memory()
	self:update_fps()
	self:update_components()
	self.layout:set_dirty()
end

--- 更新内存显示：获取当前Lua内存使用量并居中显示
function M:update_memory()
	-- 获取当前Lua内存使用量（KB）
	local memory = collectgarbage("count")
	self.text_memory_amount:set_text(tostring(math.ceil(memory)))

	-- 将内存相关节点居中对齐
	local width = helper.centrate_nodes(2, unpack(self.nodes_memory))
	for index = 1, #self.nodes_memory do
		local node = self.nodes_memory[index]
		local position_x = gui.get(node, "position.x")
		gui.set(node, "position.x", position_x + width / 2)
	end
	self.group_memory:set_size(width, nil)
end

--- 更新FPS显示：根据采样的帧时间计算平均FPS和最低FPS
function M:update_fps()
	local average_frame_time = 0
	local max_frame_time = 0
	-- 遍历所有采样的帧时间
	for index = 1, #self.fps_samples do
		average_frame_time = average_frame_time + self.fps_samples[index]
		max_frame_time = math.max(max_frame_time, self.fps_samples[index])
	end
	average_frame_time = average_frame_time / #self.fps_samples

	-- 计算并显示平均FPS和最低FPS
	self.text_fps_amount:set_text(tostring(math.ceil(1 / average_frame_time)))
	self.text_fps_min:set_text("/ " .. tostring(math.ceil(1 / max_frame_time)))

	-- 将FPS相关节点居中对齐
	local width = helper.centrate_nodes(2, unpack(self.nodes_fps))
	self.group_fps:set_size(width, nil)
end

--- 更新组件数量显示：统计当前Druid管理的组件总数
function M:update_components()
	---@diagnostic disable-next-line, invisible
	-- 获取Druid实例中所有组件的数量
	local components = #self.druid.components_all

	self.text_components_amount:set_text(tostring(components))
	-- 将组件数量相关节点居中对齐
	local width = helper.centrate_nodes(2, unpack(self.nodes_components))
	self.group_components:set_size(width, nil)
end

--- 每帧更新：采样当前帧时间用于FPS计算
function M:update()
	self:sample_fps()
end

--- 采样FPS：记录每帧的时间间隔，维护一个固定大小的采样队列
function M:sample_fps()
	if not self.previous_time then
		-- 第一次调用时记录初始时间
		self.previous_time = socket.gettime()
		return
	end

	-- 计算与上一帧的时间差
	local current_time = socket.gettime()
	local delta_time = current_time - self.previous_time
	self.previous_time = current_time

	-- 将帧时间添加到采样队列
	table.insert(self.fps_samples, delta_time)
	-- 如果采样数量超过限制，移除最旧的采样
	if #self.fps_samples > FPS_SAMPLES then
		table.remove(self.fps_samples, 1)
	end
end

--- 手动触发垃圾回收：点击内存按钮时执行
function M:run_collectgarbage()
	collectgarbage("collect")
end

return M
