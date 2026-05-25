local panthera = require("panthera.panthera")

local basic_animation_panthera = require("example.examples.panthera.basic_animation.basic_animation_panthera")

--- 基础动画示例：展示Panthera动画系统的按钮悬停和点击动画效果
---@class examples.basic_animation: druid.widget
---@field animation panthera.animation
---@field button druid.button
local M = {}


--- 初始化函数：创建Panthera动画并绑定按钮的悬停和点击事件
function M:init()
	-- 从配置文件创建GUI动画
	self.animation = panthera.create_gui(basic_animation_panthera, self:get_template(), self:get_nodes())

	-- 创建按钮，点击时播放点击动画
	self.button = self.druid:new_button("button/root", function()
		panthera.play(self.animation, "on_click", {
			is_skip_init = true
		})
	end)
	-- 清除按钮默认样式动画（避免与 panthera 动画叠加）
	self.button:set_style(nil)

	-- 订阅鼠标悬停事件，根据悬停状态播放不同动画
	self.button.hover.on_mouse_hover:subscribe(function(_, is_hover)
		if is_hover then
			-- 鼠标进入时播放悬停动画
			panthera.play(self.animation, "on_hover")
		else
			-- 鼠标离开时播放重置动画，跳过初始状态
			panthera.play(self.animation, "reset", {
				is_skip_init = true
			})
		end
	end)
end

return M
