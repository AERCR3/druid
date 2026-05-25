--- 基础按钮示例：展示按钮的点击功能和属性面板控制
---@class examples.basic_button: druid.widget
---@field button druid.button
local M = {}

--- 初始化函数：创建按钮并设置点击回调
function M:init()
	-- 创建按钮并设置点击回调函数
	self.button = self.druid:new_button("button/root", function()
		print("按钮已按下")
	end)
end

--- 示例创建回调：订阅按钮点击事件并记录日志
---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅按钮点击事件，当按钮被点击时向日志添加消息
	self.button.on_click:subscribe(function()
		output_log:add_log_text("按钮已点击")
	end)
end

--- 属性面板控制：添加启用/禁用复选框
---@param properties_panel properties_panel
function M:properties_control(properties_panel)
	local checkbox = properties_panel:add_checkbox("ui_enabled", false, function(value)
		self.button:set_enabled(value)
	end)
	checkbox:set_value(true)
end

return M
