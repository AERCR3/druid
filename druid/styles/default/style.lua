--- Druid默认样式定义文件
--- 此文件定义了Druid UI框架的各种组件的默认视觉样式和行为
local settings = require("druid.system.settings")

local M = {}


--- 按钮组件样式定义
M["button"] = {
	HOVER_SCALE = vmath.vector3(0.08, 0.08, 1),      -- 悬停时的缩放增量
	HOVER_MOUSE_SCALE = vmath.vector3(0.04, 0.04, 1), -- 鼠标悬停时的缩放增量
	HOVER_TIME = 0.05,                               -- 悬停动画持续时间
	SCALE_CHANGE = vmath.vector3(0.12, 0.12, 1),     -- 点击时的缩放变化
	BTN_SOUND = "click",                             -- 按钮点击音效
	BTN_SOUND_DISABLED = "click",                    -- 禁用按钮点击音效
	DISABLED_COLOR = vmath.vector4(0, 0, 0, 1),      -- 禁用状态颜色
	ENABLED_COLOR = vmath.vector4(1),                -- 启用状态颜色
	LONGTAP_TIME = 0.4,                              -- 长按触发时间
	AUTOHOLD_TRIGGER = 0.8,                          -- 自动按住触发阈值
	DOUBLETAP_TIME = 0.4,                            -- 双击时间间隔

	--- 初始化回调
	on_init = function(self) end,

	--- 悬停状态回调
	--- @param self 按钮组件实例
	--- @param node GUI节点
	--- @param state 是否悬停状态
	on_hover = function(self, node, state)
		local scale_to = self.start_scale + M.button.HOVER_SCALE

		local target_scale = state and scale_to or self.start_scale
		gui.animate(node, "scale", target_scale, gui.EASING_OUTSINE, M.button.HOVER_TIME)
	end,

	--- 鼠标悬停状态回调
	--- @param self 按钮组件实例
	--- @param node GUI节点
	--- @param state 是否悬停状态
	on_mouse_hover = function(self, node, state)
		local scale_to = self.start_scale + M.button.HOVER_MOUSE_SCALE

		local target_scale = state and scale_to or self.start_scale
		gui.animate(node, "scale", target_scale, gui.EASING_OUTSINE, M.button.HOVER_TIME)
	end,

	--- 点击回调
	--- @param self 按钮组件实例
	--- @param node GUI节点
	on_click = function(self, node)
		local scale_to = self.start_scale + M.button.SCALE_CHANGE
		gui.set_scale(node, scale_to)

		local is_hover = self.hover:is_mouse_hovered()
		local target_scale = is_hover and self.start_scale + M.button.HOVER_MOUSE_SCALE or self.start_scale
		gui.animate(node, gui.PROP_SCALE, target_scale, gui.EASING_OUTBACK, 0.24)

		settings.play_sound(M.button.BTN_SOUND)
	end,

	--- 禁用状态点击回调
	--- @param self 按钮组件实例
	--- @param node GUI节点
	on_click_disabled = function(self, node)
		local start_pos = self.start_pos
		gui.animate(node, "position.x", start_pos.x - 3, gui.EASING_OUTSINE, 0.05, 0, function()
			gui.animate(node, "position.x", start_pos.x + 3, gui.EASING_OUTSINE, 0.1, 0, function()
				gui.animate(node, "position.x", start_pos.x, gui.EASING_OUTSINE, 0.05)
			end)
		end)
	end,

	--- 设置启用状态回调
	--- @param self 按钮组件实例
	--- @param node GUI节点
	--- @param state 是否启用
	on_set_enabled = function(self, node, state)
	end,
}

--- 悬停组件样式定义
M["hover"] = {
	ON_HOVER_CURSOR = nil,      -- 悬停时光标的样式
	ON_MOUSE_HOVER_CURSOR = nil, -- 鼠标悬停时光标的样式
}

--- 拖动组件样式定义
M["drag"] = {
	DRAG_DEADZONE = 4,         -- 拖动死区的像素大小
	NO_USE_SCREEN_KOEF = false, -- 是否不使用屏幕系数
}


--- 网格组件样式定义
M["grid"] = {
	IS_DYNAMIC_NODE_POSES = false, -- 总是根据内容大小与节点锚点对齐
	IS_ALIGN_LAST_ROW = true,     -- 对齐网格的最后一行
}


--- 滚动组件样式定义
M["scroll"] = {
	ANIM_SPEED = 0.2,                -- 滚动到目标点的动画速度
	BACK_SPEED = 0.1,                -- 返回软位置的插值速度
	FRICT = 0.93,                    -- 自由惯性的乘数
	FRICT_HOLD = 0.79,               -- 触摸时惯性的乘数
	INERT_THRESHOLD = 2.5,           -- 停止惯性的速度阈值
	INERT_SPEED = 30,                -- 惯性速度系数
	EXTRA_STRETCH_SIZE = 100,        -- 滚动区域外的额外像素大小（拉伸效果）
	POINTS_DEADZONE = 20,            -- 无惯性模式下检查兴趣点的速度
	WHEEL_SCROLL_SPEED = 20,         -- 单次滚轮事件滚动的像素量（0为禁用）
	WHEEL_SCROLL_INVERTED = true,    -- 是否反转滚轮滚动方向
	WHEEL_SCROLL_BY_INERTION = false, -- 如果为真，滚轮将为滚动添加惯性；否则直接设置位置
	SMALL_CONTENT_SCROLL = false,    -- 如果为真，内容节点小于视图节点大小时也可以滚动
}


--- 进度条组件样式定义
M["progress"] = {
	SPEED = 5,       -- 进度条填充速率，越大越快
	MIN_DELTA = 0.005 -- 最小步长
}


--- 滑块组件样式定义
M["slider"] = {
	DEFAULT_STEPS = {}, -- 默认步骤，例如{0, 0.25, 0.5, 0.75, 1}表示带刻度的滑块；空表示连续
}


M["swipe"] = {
	SWIPE_THRESHOLD = 50,
	SWIPE_TIME = 0.4,
	SWIPE_TRIGGER_ON_MOVE = true
}


M["input"] = {
	IS_LONGTAP_ERASE = false,
	BUTTON_SELECT_INCREASE = 1.08,
	MASK_DEFAULT_CHAR = "*",
	IS_UNSELECT_ON_RESELECT = false,

	on_init = function(self) end,

	on_select = function(self, button_node)
		local target_scale = self.button.start_scale
		gui.animate(button_node, "scale", target_scale * M.input.BUTTON_SELECT_INCREASE, gui.EASING_OUTSINE, 0.15)
	end,

	on_unselect = function(self, button_node)
		local start_scale = self.button.start_scale
		gui.animate(button_node, "scale", start_scale, gui.EASING_OUTSINE, 0.15)
	end,

	on_input_wrong = function(self, button_node)
		local start_pos = self.button.start_pos
		gui.animate(button_node, "position.x", start_pos.x - 3, gui.EASING_OUTSINE, 0.05, 0, function()
			gui.animate(button_node, "position.x", start_pos.x + 3, gui.EASING_OUTSINE, 0.1, 0, function()
				gui.animate(button_node, "position.x", start_pos.x, gui.EASING_OUTSINE, 0.05)
			end)
		end)
	end,
}


M["text"] = {
	TRIM_POSTFIX = "...",
	DEFAULT_ADJUST = "downscale"
}


M["hotkey"] = {
	-- Add key ids to mark it as modificator keys
	MODIFICATORS = {
		"key_lshift",
		"key_rshift",
		"key_lctrl",
		"key_rctrl",
		"key_lalt",
		"key_ralt",
		"key_lsuper",
		"key_rsuper"
	}
}


return M
