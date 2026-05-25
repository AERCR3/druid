local panthera = require("panthera.panthera")

local animation = require("example.examples.basic.button.basic_button_hold_panthera")

--- 长按按钮示例：展示按钮的长按、自动触发和动画效果
---@class examples.basic_button_hold: druid.widget
---@field button druid.button
local M = {}


--- 初始化函数：创建Panthera动画和按钮，订阅长按和悬停事件
function M:init()
	-- 创建Panthera动画实例
	self.animation = panthera.create_gui(animation, self:get_template(), self:get_nodes())

	-- 创建按钮并设置点击回调
	self.button = self.druid:new_button("button", function()
		print("点击")
	end)

	self.button:set_style({})
	self.button.style.AUTOHOLD_TRIGGER = 2
	self.button.style.LONGTAP_TIME = 0

	self.button.on_hold_callback:subscribe(function(_, _, _, time)
		local start_time = self.button.style.LONGTAP_TIME
		local max_time = self.button.style.AUTOHOLD_TRIGGER
		local progress = (time - start_time) / (max_time - start_time)
		panthera.set_time(self.animation, "hold", progress)
	end)

	self.button.on_long_click:subscribe(function()
		panthera.play(self.animation, "complete")
	end)

	self.button.hover.on_mouse_hover:subscribe(function(_, state)
		if not state then
			panthera.set_time(self.animation, "hold", 0)
		end
	end)

	self.button.on_click_outside:subscribe(function()
		panthera.set_time(self.animation, "hold", 0)
	end)
end

---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅单击事件并记录日志
	self.button.on_click:subscribe(function()
		output_log:add_log_text("已点击")
	end)
	-- 订阅长按事件并记录日志
	self.button.on_long_click:subscribe(function()
		output_log:add_log_text("长按点击")
	end)
end

return M
