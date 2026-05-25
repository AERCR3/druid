--- 按钮组件：数据列表中使用的缓存按钮控件，可设置和获取数据
---@class examples.button_component: druid.widget
---@field root node
---@field text druid.text
---@field button druid.button
---@field data any
local M = {}


--- 初始化函数：创建按钮和文本控件
function M:init()
	self.root = self:get_node("root")

	self.button = self.druid:new_button(self.root)
	self.text = self.druid:new_text("text")

	-- 初始化数据为空
	self.data = nil
end

--- 设置按钮关联的数据
---@param data any 任意类型的数据
function M:set_data(data)
	self.data = data
end

--- 获取按钮关联的数据
---@return any
function M:get_data()
	return self.data
end

return M
