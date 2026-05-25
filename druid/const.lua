---Druid系统常量类，定义了输入动作、事件类型和优先级等核心常量
---@class druid.system.const
local M = {}

---输入动作常量定义
M.ACTION_TEXT = hash(sys.get_config_string("druid.input_text", "text"))                           -- 文本输入动作
M.ACTION_TOUCH = hash(sys.get_config_string("druid.input_touch", "touch"))                        -- 触摸动作
M.ACTION_MARKED_TEXT = hash(sys.get_config_string("druid.input_marked_text", "marked_text"))      -- 标记文本动作
M.ACTION_ESC = hash(sys.get_config_string("druid.input_key_esc", "key_esc"))                      -- ESC键动作
M.ACTION_BACK = hash(sys.get_config_string("druid.input_key_back", "key_back"))                   -- 返回键动作
M.ACTION_ENTER = hash(sys.get_config_string("druid.input_key_enter", "key_enter"))                -- 回车键动作
M.ACTION_SPACE = hash(sys.get_config_string("druid.input_key_space", "key_space"))                -- 空格键动作
M.ACTION_MULTITOUCH = hash(sys.get_config_string("druid.input_multitouch", "touch_multi"))        -- 多点触控动作
M.ACTION_BACKSPACE = hash(sys.get_config_string("druid.input_key_backspace", "key_backspace"))    -- 退格键动作
M.ACTION_SCROLL_UP = hash(sys.get_config_string("druid.input_scroll_up", "mouse_wheel_up"))       -- 鼠标滚轮向上滚动动作
M.ACTION_SCROLL_DOWN = hash(sys.get_config_string("druid.input_scroll_down", "mouse_wheel_down")) -- 鼠标滚轮向下滚动动作
M.ACTION_LEFT = hash(sys.get_config_string("druid.input_key_left", "key_left"))                   -- 左箭头键动作
M.ACTION_RIGHT = hash(sys.get_config_string("druid.input_key_right", "key_right"))                -- 右箭头键动作
M.ACTION_UP = hash(sys.get_config_string("druid.input_key_up", "key_up"))                         -- 上箭头键动作
M.ACTION_DOWN = hash(sys.get_config_string("druid.input_key_down", "key_down"))                   -- 下箭头键动作
M.ACTION_LSHIFT = hash(sys.get_config_string("druid.input_key_lshift", "key_lshift"))             -- 左Shift键动作
M.ACTION_LCTRL = hash(sys.get_config_string("druid.input_key_lctrl", "key_lctrl"))                -- 左Ctrl键动作
M.ACTION_LCMD = hash(sys.get_config_string("druid.input_key_lsuper", "key_lsuper"))               -- 左命令键动作（Mac）

---事件类型常量定义
M.ON_INPUT = "on_input"                     -- 输入事件
M.ON_UPDATE = "update"                      -- 更新事件
M.ON_MESSAGE = "on_message"                 -- 消息事件
M.ON_LATE_INIT = "on_late_init"             -- 延迟初始化事件
M.ON_FOCUS_LOST = "on_focus_lost"           -- 焦点丢失事件
M.ON_FOCUS_GAINED = "on_focus_gained"       -- 焦点获得事件
M.ON_LAYOUT_CHANGE = "on_layout_change"     -- 布局变更事件
M.ON_WINDOW_RESIZED = "on_window_resized"   -- 窗口调整大小事件
M.ON_LANGUAGE_CHANGE = "on_language_change" -- 语言变更事件

M.ALL_INTERESTS = {
	M.ON_INPUT,
	M.ON_UPDATE,
	M.ON_MESSAGE,
	M.ON_LATE_INIT,
	M.ON_FOCUS_LOST,
	M.ON_FOCUS_GAINED,
	M.ON_LAYOUT_CHANGE,
	M.ON_WINDOW_RESIZED,
	M.ON_LANGUAGE_CHANGE,
}

M.MSG_LAYOUT_CHANGED = hash("layout_changed")

---组件处理优先级常量定义（值越高越先处理）
M.PRIORITY_INPUT = 10      -- 输入组件优先级
M.PRIORITY_INPUT_HIGH = 20 -- 高输入优先级
M.PRIORITY_INPUT_MAX = 100 -- 最大输入优先级

M.PIVOTS = {
	[gui.PIVOT_CENTER] = vmath.vector3(0),
	[gui.PIVOT_N] = vmath.vector3(0, 0.5, 0),
	[gui.PIVOT_NE] = vmath.vector3(0.5, 0.5, 0),
	[gui.PIVOT_E] = vmath.vector3(0.5, 0, 0),
	[gui.PIVOT_SE] = vmath.vector3(0.5, -0.5, 0),
	[gui.PIVOT_S] = vmath.vector3(0, -0.5, 0),
	[gui.PIVOT_SW] = vmath.vector3(-0.5, -0.5, 0),
	[gui.PIVOT_W] = vmath.vector3(-0.5, 0, 0),
	[gui.PIVOT_NW] = vmath.vector3(-0.5, 0.5, 0),
}

M.REVERSE_PIVOTS = {
	[gui.PIVOT_CENTER] = gui.PIVOT_CENTER,
	[gui.PIVOT_N] = gui.PIVOT_S,
	[gui.PIVOT_NE] = gui.PIVOT_SW,
	[gui.PIVOT_E] = gui.PIVOT_W,
	[gui.PIVOT_SE] = gui.PIVOT_NW,
	[gui.PIVOT_S] = gui.PIVOT_N,
	[gui.PIVOT_SW] = gui.PIVOT_NE,
	[gui.PIVOT_W] = gui.PIVOT_E,
	[gui.PIVOT_NW] = gui.PIVOT_SE,
}

M.LAYOUT_MODE = {
	STRETCH_X = "stretch_x",
	STRETCH_Y = "stretch_y",
	FIT = "fit",
	STRETCH = "stretch",
}

---当前系统名称
M.CURRENT_SYSTEM_NAME = sys.get_sys_info().system_name

---操作系统类型常量定义
M.OS = {
	ANDROID = "Android", -- 安卓系统
	IOS = "iPhone OS",  -- iOS系统
	MAC = "Darwin",     -- Mac系统
	LINUX = "Linux",    -- Linux系统
	WINDOWS = "Windows", -- Windows系统
	BROWSER = "HTML5",  -- 浏览器环境
}

---文本偏移常量定义
M.SHIFT = {
	NO_SHIFT = 0, -- 无偏移
	LEFT = -1,   -- 左偏移
	RIGHT = 1,   -- 右偏移
}

---文本调整类型常量定义
M.TEXT_ADJUST = {
	DOWNSCALE = "downscale",                      -- 缩小适应（默认）
	NO_ADJUST = "no_adjust",                      -- 不调整
	DOWNSCALE_LIMITED = "downscale_limited",      -- 限制缩小适应
	SCROLL = "scroll",                            -- 滚动
	TRIM = "trim",                                -- 修剪
	TRIM_LEFT = "trim_left",                      -- 左侧修剪
	SCALE_THEN_TRIM = "scale_then_trim",          -- 先缩放后修剪
	SCALE_THEN_TRIM_LEFT = "scale_then_trim_left", -- 先缩放后左侧修剪
	SCALE_THEN_SCROLL = "scale_then_scroll",      -- 先缩放后滚动
}

---方向常量定义
M.SIDE = {
	X = "x", -- X方向
	Y = "y" -- Y方向
}

return M
