--- 9切片进度条示例：展示使用9切片图像的进度条
---@class examples.basic_progress_bar_slice9: druid.widget
---@field progress druid.progress
local M = {}


--- 初始化函数：创建9切片进度条和值显示文本
function M:init()
	self.progress = self.druid:new_progress("progress_bar_fill", "x")
	self.text_value = self:get_node("progress_value")

	self:set_value(self.progress:get())
end

--- 设置进度值：更新9切片进度条和百分比文本
---@param value number 进度值（0-1）
function M:set_value(value)
	gui.set_text(self.text_value, math.ceil(value * 100) .. "%")
	self.progress:set_to(value)
end

--- 属性面板控制：添加进度值滑块
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	properties_panel:add_slider("ui_value", 1, function(value)
		self:set_value(value)
	end)
end

return M
