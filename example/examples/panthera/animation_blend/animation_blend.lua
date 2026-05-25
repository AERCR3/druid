local panthera = require("panthera.panthera")
local helper = require("druid.helper")
local event = require("event.event")

local character_animation_blend = require("example.examples.panthera.animation_blend.character_animation_blend")

--- 动画混合示例：展示Panthera动画系统的混合功能，通过鼠标位置控制角色动画
---@class examples.animation_blend: druid.widget
---@field root node
---@field root_size vector3
---@field animation_idle panthera.animation
---@field animation_vertical panthera.animation
---@field animation_horizontal panthera.animation
---@field rich_text druid.rich_text
---@field on_update event
local M = {}


--- 初始化函数：创建三个动画实例（待机、垂直、水平）并设置富文本
function M:init()
	self.root = self:get_node("root")
	self.root_size = gui.get_size(self.root)
	self.druid:new_lang_text("text_hint", "ui_example_panthera_animation_blend_hint")

	-- 创建三个独立的动画实例，用于混合控制
	self.animation_idle = panthera.create_gui(character_animation_blend, self:get_template(), self:get_nodes())
	self.animation_vertical = panthera.create_gui(character_animation_blend, self:get_template(), self:get_nodes())
	self.animation_horizontal = panthera.create_gui(character_animation_blend, self:get_template(), self:get_nodes())

	-- 播放待机动画，设置为循环
	panthera.play(self.animation_idle, "idle", {
		is_loop = true,
	})

	-- 设置富文本链接
	self:setup_rich_text()
	self.on_update = event.create()
end

--- 输入处理：根据鼠标在根节点上的位置，计算并设置水平和垂直动画的进度
---@param action_id hash 动作ID
---@param action action 动作数据
function M:on_input(action_id, action)
	-- 检查鼠标是否在根节点范围内
	if action_id == nil and gui.pick_node(self.root, action.x, action.y) then
		local root_screen_pos = gui.get_screen_position(self.root)
		local koef_x, koef_y = helper.get_screen_aspect_koef()

		-- 计算水平方向的偏移量，并归一化为0-1的动画进度
		local dx = (action.screen_x - root_screen_pos.x) * koef_x                 -- 范围：-root_size.x/2 .. root_size.x/2
		local animation_progress_x = (dx + self.root_size.x / 2) / self.root_size.x -- 归一化到 0..1
		panthera.set_time(self.animation_horizontal, "horizontal", animation_progress_x)

		-- 计算垂直方向的偏移量，并归一化为0-1的动画进度
		local dy = (action.screen_y - root_screen_pos.y) * koef_y                 -- 范围：-root_size.y/2 .. root_size.y/2
		local animation_progress_y = (dy + self.root_size.y / 2) / self.root_size.y -- 归一化到 0..1
		panthera.set_time(self.animation_vertical, "vertical", animation_progress_y)
	end
end

--- 每帧更新：触发on_update事件，用于同步UI滑块
function M:update()
	self.on_update:trigger()
end

--- 设置富文本：创建带链接的文本，点击链接可打开外部网页
function M:setup_rich_text()
	-- 创建富文本，包含Kenney的链接
	self.rich_text = self.druid:new_rich_text("rich_text_kenney",
		"Character assets by <color=865BD9><link>Kenney</link></color>")

	-- 查找所有标记为"link"的文本片段，并为它们添加按钮功能
	local tagged = self.rich_text:tagged("link")
	for index = 1, #tagged do
		---@type druid.rich_text.word
		local word = tagged[index]
		-- 为链接文本添加点击事件，打开Kenney官网
		self.druid:new_button(word.node, function()
			sys.open_url("https://kenney.nl/")
		end)
	end
end

--- 属性面板控制：添加垂直和水平动画的滑块控制器
---@param properties_panel properties_panel 属性面板实例
function M:properties_control(properties_panel)
	-- 获取当前垂直动画的时间进度
	local vertical_time = panthera.get_time(self.animation_vertical)

	-- 添加垂直动画滑块，允许手动控制动画进度
	local vertical_slider = properties_panel:add_slider("ui_animation_vertical", vertical_time, function(value)
		panthera.set_time(self.animation_vertical, "vertical", value)
	end)

	-- 获取当前水平动画的时间进度
	local horizontal_time = panthera.get_time(self.animation_horizontal)

	-- 添加水平动画滑块，允许手动控制动画进度
	local horizontal_slider = properties_panel:add_slider("ui_animation_horizontal", horizontal_time, function(value)
		panthera.set_time(self.animation_horizontal, "horizontal", value)
	end)

	-- 订阅更新事件，实时同步滑块值与动画进度
	self.on_update:subscribe(function()
		vertical_slider:set_value(panthera.get_time(self.animation_vertical))
		horizontal_slider:set_value(panthera.get_time(self.animation_horizontal))
	end)
end

return M
