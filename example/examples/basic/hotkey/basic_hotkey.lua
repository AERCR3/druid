--- 快捷键示例：展示快捷键绑定和释放事件的处理
---@class examples.basic_hotkey: druid.widget
---@field root node
---@field text druid.text
local M = {}


--- 初始化函数：创建快捷键绑定（Shift+X）
function M:init()
	self.root = self:get_node("root")
	self.hotkey = self.druid:new_hotkey({ "key_lshift", "key_x" }, self.on_hotkey)
end

--- 快捷键回调：播放缩放动画
function M:on_hotkey()
	gui.animate(self.root, gui.PROP_SCALE, vmath.vector3(1.2), gui.EASING_OUTELASTIC, 0.5, 0, function()
		gui.animate(self.root, gui.PROP_SCALE, vmath.vector3(1), gui.EASING_OUTELASTIC, 0.5)
	end)
end

---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅快捷键释放事件并记录日志
	self.hotkey.on_hotkey_released:subscribe(function()
		output_log:add_log_text("快捷键已释放")
	end)
end

return M
