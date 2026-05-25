local component = require("druid.component")

--- 输出列表面板组件：显示日志消息列表，支持自动滚动和最大条目限制
---@class output_list: druid.component
---@field root druid.container
---@field text_header druid.text
---@field scroll druid.scroll
---@field druid druid.instance
local M = component.create("output_list")

--- 初始化函数：创建滚动视图、网格布局和版本信息显示
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加标题和分隔线锚点
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_header")
	self.root:add_container("separator")

	self.created_texts = {}
	-- 获取文本预制件并禁用，用于后续克隆
	self.prefab = self:get_node("text")
	gui.set_enabled(self.prefab, false)

	-- 创建网格布局和滚动视图，并绑定在一起
	self.grid = self.druid:new_grid("scroll_content", "text", 1)
	self.scroll = self.druid:new_scroll("scroll_view", "scroll_content")
	self.scroll:bind_grid(self.grid)
	self.scroll:set_horizontal_scroll(false)

	-- 创建标题文本
	self.druid:new_lang_text("text_header", "ui_output")

	-- 显示Defold引擎版本
	local defold_version = sys.get_engine_info().version
	gui.set_text(self:get_node("text_version_defold"), "Defold v" .. defold_version)

	-- 显示Druid框架版本
	local druid_version = sys.get_config_string("project.version")
	gui.set_text(self:get_node("text_version_druid"), "Druid v" .. druid_version)
end

--- 添加日志文本：创建新的日志条目并添加到列表底部，自动滚动到底部
---@param text string 要显示的日志文本
function M:add_log_text(text)
	-- 克隆预制件节点并启用
	local text_node = gui.clone(self.prefab)
	gui.set_enabled(text_node, true)

	-- 创建文本实例并添加到网格
	local text_instance = self.druid:new_text(text_node, text)
	self.grid:add(text_instance.node)
	table.insert(self.created_texts, text_instance)

	-- 滚动到列表底部（显示最新日志）
	self.scroll:scroll_to_percent(vmath.vector3(0, 0, 0))

	-- 如果日志数量超过64条，移除最旧的日志
	if #self.created_texts > 64 then
		self.grid:remove(1)
		self.druid:remove(self.created_texts[1])
		gui.delete_node(self.created_texts[1].node)
		table.remove(self.created_texts, 1)
	end
end

--- 清空所有日志：移除所有日志文本和网格项
function M:clear()
	-- 移除所有文本实例
	for index = 1, #self.created_texts do
		self.druid:remove(self.created_texts[index])
	end

	-- 删除所有网格节点
	local nodes = self.grid.nodes
	for index = 1, #nodes do
		gui.delete_node(nodes[index])
	end
	self.created_texts = {}
	self.grid:clear()
end

return M
