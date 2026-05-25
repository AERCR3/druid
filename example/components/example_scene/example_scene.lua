local component = require("druid.component")

--- 示例场景组件：显示调试信息和GUI路径，用于示例展示
---@class examples.example_scene: druid.component
---@field root druid.container
---@field text_debug_info druid.text
---@field text_gui_path druid.text
---@field druid druid.instance
local M = component.create("example_scene")


--- 初始化函数：创建容器和文本组件，用于显示调试信息和GUI路径
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加两个文本锚点
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_debug_info")
	self.root:add_container("text_gui_path")

	-- 创建调试信息文本和GUI路径文本
	self.text_debug_info = self.druid:new_text("text_debug_info")
	self.text_gui_path = self.druid:new_text("text_gui_path", "")
end

--- 设置调试信息：更新调试信息文本内容
---@param info string 调试信息字符串
function M:set_debug_info(info)
	self.text_debug_info:set_text(info)
end

--- 设置GUI路径：将Lua文件路径转换为对应的.gui资源路径并显示
---@param path string Lua文件的相对路径
function M:set_gui_path(path)
	-- path 是示例 lua 文件的相对路径
	-- 这里转换成对应的 .gui 资源路径：前面补 "/"，并把 .lua 替换为 .gui
	path = "/" .. path:gsub(".lua", ".gui")

	self.text_gui_path:set_text(path)
end

return M
