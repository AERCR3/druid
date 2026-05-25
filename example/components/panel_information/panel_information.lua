local lang = require("lang.lang")
local component = require("druid.component")

--- 信息面板组件：显示示例说明文本，支持性能分析器切换和查看代码功能
---@class panel_information: druid.component
---@field root druid.container
---@field text_header druid.lang_text
---@field rich_text druid.rich_text
---@field druid druid.instance
local PanelInformation = component.create("panel_information")

--- 初始化函数：创建容器、富文本、按钮和快捷键绑定
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function PanelInformation:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	-- 创建根容器并添加多个锚点用于布局
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.root:add_container("text_header")
	self.root:add_container("scroll_view")
	self.root:add_container("S_Anchor")
	self.root:add_container("NE_Anchor")

	-- 创建标题文本和性能分析器按钮文本
	self.druid:new_lang_text("text_header", "ui_information")
	self.druid:new_lang_text("button_profiler/text", "ui_profiler")

	--self.text_description = self.druid:new_lang_text("text_description", "") --[[@as druid.lang_text]]
	-- 创建富文本用于显示说明内容
	self.rich_text = self.druid:new_rich_text("text_description")
	-- 创建性能分析器按钮，并设置快捷键P
	self.button_profiler = self.druid:new_button("button_profiler/root", self.on_profiler_click)
	self.button_profiler:set_key_trigger("key_p")
	-- 创建查看代码按钮
	self.button_view_code = self.druid:new_button("button_view_code/root")

	-- 网页平台下禁用性能分析器按钮
	gui.set_enabled(self.button_profiler.node, not html5)
end

--- 设置说明文本：根据文本ID获取本地化文本并显示在富文本中
---@param text_id string 文本ID（用于本地化）
function PanelInformation:set_text(text_id)
	local text = lang.txt(text_id)
	self.rich_text:set_text(text)
end

--- 性能分析器按钮点击回调：循环切换性能分析器的显示模式（隐藏 -> 最小化 -> 全屏）
function PanelInformation:on_profiler_click()
	if self._profiler_mode == nil then
		-- 第一次点击：启用并设置为最小化模式
		self._profiler_mode = profiler.VIEW_MODE_MINIMIZED
		profiler.enable_ui(true)
		profiler.set_ui_view_mode(self._profiler_mode)
	elseif self._profiler_mode == profiler.VIEW_MODE_MINIMIZED then
		-- 第二次点击：切换到全屏模式
		self._profiler_mode = profiler.VIEW_MODE_FULL
		profiler.enable_ui(true)
		profiler.set_ui_view_mode(self._profiler_mode)
	else
		-- 第三次点击：禁用性能分析器
		self._profiler_mode = nil
		profiler.enable_ui(false)
	end
end

return PanelInformation
