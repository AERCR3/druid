local component = require("druid.component")

---@class examples.example_scene: druid.component
---@field root druid.container
---@field text_debug_info druid.text
---@field text_gui_path druid.text
---@field druid druid.instance
local M = component.create("example_scene")


---@param template string
---@param nodes table<hash, node>
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_debug_info")
	self.root:add_container("text_gui_path")

	self.text_debug_info = self.druid:new_text("text_debug_info")
	self.text_gui_path = self.druid:new_text("text_gui_path", "")
end


---@param info string
function M:set_debug_info(info)
	self.text_debug_info:set_text(info)
end


---@param path string
function M:set_gui_path(path)
	-- path 是示例 lua 文件的相对路径
	-- 这里转换成对应的 .gui 资源路径：前面补 "/"，并把 .lua 替换为 .gui
	path = "/" .. path:gsub(".lua", ".gui")

	self.text_gui_path:set_text(path)
end


return M
