local panthera = require("panthera.panthera")

local animation = require("example.other.go_bindings.go_widget_panthera")
local memory_panel = require("druid.widget.memory_panel.memory_panel")

--- GO绑定控件示例：展示如何在游戏对象中使用Druid Widget，包含动画和内存面板
---@class druid.widget.go_widget: druid.widget
local M = {}


--- 初始化函数：创建节点引用、动画和内存面板
function M:init()
	-- 打印控件初始化信息，包含消息URL
	print("初始化控件", msg.url())
	self.root = self:get_node("root")
	self.circle = self:get_node("circle")
	-- 创建Panthera动画
	self.animation = panthera.create_gui(animation)
	self.counter = 0
	self.text_counter = self:get_node("text")
	gui.set_text(self.text_counter, 0)

	-- 创建内存面板组件
	self.memory_panel = self.druid:new_widget(memory_panel, "memory_panel")
end

--- 播放动画：启动循环动画，每次循环完成时增加计数器
function M:play_animation()
	panthera.play(self.animation, "default", {
		is_loop = true,
		callback = function()
			-- 动画循环完成时，增加计数并更新显示
			self.counter = self.counter + 1
			gui.set_text(self.text_counter, self.counter)
		end
	})
end

---@param position vector3 要设置的位置
function M:set_position(position)
	gui.set_position(self.root, position)
end

return M
