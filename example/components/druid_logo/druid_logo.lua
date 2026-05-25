local panthera = require("panthera.panthera")
local component = require("druid.component")

local druid_logo_panthera = require("example.components.druid_logo.druid_logo_panthera")

--- Druid Logo组件：展示带悬停动画的可点击Logo，点击后打开GitHub页面
---@class examples.druid_logo: druid.component
---@field root druid.container
---@field text_description druid.text
---@field druid druid.instance
local DruidLogo = component.create("druid_logo")


--- 初始化函数：创建容器、按钮、动画和悬停效果
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function DruidLogo:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加东西两侧的锚点
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("E_Anchor")
	self.root:add_container("W_Anchor")

	-- 创建可点击的按钮，点击后打开链接
	self.druid:new_button("root", self.on_click):set_style(nil)

	-- 创建并播放待机动画（循环）
	self.animation = panthera.create_gui(druid_logo_panthera, self:get_template(), nodes)
	panthera.play(self.animation, "idle", { is_loop = true })

	-- 克隆动画状态用于悬停效果
	self.animation_hover = panthera.clone_state(self.animation)
	self.hover = self.druid:new_hover("root")
	self.hover.on_mouse_hover:subscribe(self.on_mouse_hover)
end

--- 点击回调：打开Druid的GitHub页面
function DruidLogo:on_click()
	sys.open_url("https://github.com/Insality/druid", { target = "_blank" })
end

--- 鼠标悬停回调：根据悬停状态播放进入或退出动画
---@param is_hover boolean 是否处于悬停状态
function DruidLogo:on_mouse_hover(is_hover)
	if is_hover then
		-- 鼠标进入时播放悬停进入动画
		panthera.play(self.animation_hover, "on_hover_in")
	else
		-- 鼠标离开时播放悬停退出动画，跳过初始状态
		panthera.play(self.animation_hover, "on_hover_out", { is_skip_init = true })
	end
end

return DruidLogo
