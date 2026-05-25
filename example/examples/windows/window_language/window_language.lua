local lang = require("lang.lang")
local druid = require("druid.druid")
local event = require("event.event")
local panthera = require("panthera.panthera")

local window_animation_panthera = require("example.examples.windows.window_animation_panthera")

--- 语言选择窗口示例：展示多语言切换功能，支持动态加载语言按钮
---@class examples.window_language: druid.widget
---@field text_header druid.text
---@field button_close druid.button
---@field lang_buttons table<string, druid.button>
---@field grid druid.grid
---@field on_language_change event
---@field animation panthera.animation
local M = {}


-- 默认语言按钮颜色: #F0FBFF
local DEFAULT_LANGUAGE_COLOR = vmath.vector4(240 / 255, 251 / 255, 255 / 255, 1.0)
-- 选中语言按钮颜色: #E6DF9F
local SELECTED_LANGUAGE_COLOR = vmath.vector4(230 / 255, 223 / 255, 159 / 255, 1.0)


--- 初始化函数：创建语言按钮网格、窗口动画和事件对象
function M:init()
	self.lang_buttons = {}
	self.created_nodes = {}
	-- 获取预制件并禁用，用于后续克隆
	self.prefab = self:get_node("button_prefab")
	gui.set_enabled(self.prefab, false)

	-- 获取当前语言ID
	self._current_lang_id = lang.get_lang()

	-- 创建关闭按钮
	self.button_close = self.druid:new_button("button_close", self.on_button_close)

	-- 创建标题文本
	self.druid:new_lang_text("text_header", "ui_language")
	-- 创建网格布局，每行2个按钮
	self.grid = self.druid:new_grid("content", self.prefab, 2)
	self.grid.style.IS_DYNAMIC_NODE_POSES = true

	-- 创建并播放窗口打开动画
	self.animation = panthera.create_gui(window_animation_panthera, self:get_template(), self:get_nodes())
	panthera.play(self.animation, "open")

	-- 加载所有可用语言
	self:load_langs()

	-- 创建语言改变事件
	self.on_language_change = event.create()
end

--- 组件移除时清理：删除所有动态创建的节点
function M:on_remove()
	for index = 1, #self.created_nodes do
		local nodes = self.created_nodes[index]
		for _, node in pairs(nodes) do
			gui.delete_node(node)
		end
	end
end

--- 加载语言列表：为每个可用语言创建按钮并添加到网格中
function M:load_langs()
	local languages = lang.get_langs()
	-- 遍历所有可用语言，创建对应的按钮
	for index = 1, #languages do
		local lang_id = languages[index]

		local template = self:get_template()
		if template and template ~= "" then
			template = template .. "/"
		end
		-- 克隆预制件节点树
		local prefab_nodes = gui.clone_tree(self.prefab)
		local root = prefab_nodes[template .. "button_prefab"]
		local button_node = prefab_nodes[template .. "button/root"]
		local text = prefab_nodes[template .. "button/text"]

		-- 创建语言按钮，点击时切换到对应语言
		local button = self.druid:new_button(button_node, self.on_language_button, lang_id)
		self.druid:new_lang_text(text, "ui_language_" .. lang_id)
		gui.set_enabled(root, true)
		self.grid:add(root)

		self.lang_buttons[lang_id] = button
		table.insert(self.created_nodes, prefab_nodes)
	end

	do -- 根据语言按钮数量调整窗口高度
		local height = self.grid:get_size().y
		gui.set(self:get_node("window"), "size.y", height + 110)
		gui.set(self:get_node("panel_header"), "position.y", (height + 110) / 2)
	end

	do -- 高亮当前语言按钮
		local current_lang_button = self.lang_buttons[self._current_lang_id]
		gui.animate(current_lang_button.node, "color", SELECTED_LANGUAGE_COLOR, gui.EASING_OUTQUAD, 0.2)
	end
end

--- 关闭按钮回调：播放窗口关闭动画
function M:on_button_close()
	panthera.play(self.animation, "close")
end

--- 语言按钮点击回调：切换语言并更新按钮颜色
---@param lang_id string 选中的语言ID
function M:on_language_button(lang_id)
	local current_lang_button = self.lang_buttons[self._current_lang_id]
	local new_lang_button = self.lang_buttons[lang_id]

	-- 更新当前语言ID并设置新语言
	self._current_lang_id = lang_id
	lang.set_lang(lang_id)
	-- 通知Druid系统语言已改变
	druid.on_language_change()

	-- 触发语言改变事件
	self.on_language_change:trigger(lang_id)

	-- 将旧语言按钮恢复为默认颜色，新语言按钮设置为选中颜色
	gui.animate(current_lang_button.node, "color", DEFAULT_LANGUAGE_COLOR, gui.EASING_OUTQUAD, 0.2)
	gui.animate(new_lang_button.node, "color", SELECTED_LANGUAGE_COLOR, gui.EASING_OUTQUAD, 0.2)
end

---@param output_list output_list
function M:on_example_created(output_list)
	-- 订阅语言改变事件并记录日志
	self.on_language_change:subscribe(function(language)
		output_list:add_log_text("语言已更改为 " .. language)
	end)
end

return M
