local event = require("event.event")
local component = require("druid.component")
local settings = require("druid.system.settings")

---用于显示本地化文本的组件，可以在语言环境更改时自动更新文本。
---它包装了Text组件，使用druid的get_text_function通过ID设置文本以处理本地化。
---
---### 设置
---使用druid创建语言文本组件: `text = druid:new_lang_text(node_name, locale_id)`
---
---### 注意事项
---- 组件在语言环境更改时自动更新文本
---- 使用druid的get_text_function通过ID获取本地化文本
---- 支持使用附加参数进行字符串格式化
---语言文本组件是多语言支持的关键组件，实现了动态文本本地化
---@class druid.lang_text: druid.component
---@field text druid.text 文本组件
---@field node node 文本组件的节点
---@field on_change event fun(self: druid.lang_text) 文本更改时触发的事件
---@field private last_locale_args table 最后一次语言环境参数
---@field private last_locale string 最后一次语言环境
local M = component.create("lang_text")


---语言文本组件构造函数
---初始化语言文本组件，设置节点、本地化ID和调整类型
---@param node string|node 节点ID或gui.get_node(node_id)
---@param locale_id string|nil 默认语言环境ID或来自节点的文本作为默认值。如果未提供，将使用节点中的文本
---@param adjust_type string|nil 文本的调整类型。默认为DOWNSCALE。参考const.TEXT_ADJUST
function M:init(node, locale_id, adjust_type)
	self.druid = self:get_druid()
	self.text = self.druid:new_text(node, locale_id, adjust_type)
	self.node = self.text.node
	self.last_locale_args = {}

	self.on_change = event.create()

	self:translate(locale_id or gui.get_text(self.node))
	self.text.on_set_text:subscribe(self.on_change.trigger, self.on_change)

	return self
end

---@private
function M:on_language_change()
	if self.last_locale then
		self:translate(self.last_locale, unpack(self.last_locale_args))
	end
end

---向语言文本组件设置原始文本。这将清除任何语言环境设置。
---此函数用于直接设置文本内容，绕过本地化系统
---@param text string 文本节点的文本
---@return druid.lang_text self 当前实例
function M:set_to(text)
	self.last_locale = nil
	self.text:set_text(text)
	self.on_change:trigger()

	return self
end

---Setup raw text to lang_text component. This will clear any locale settings.
---@param text string Text for text node
---@return druid.lang_text self Current instance
function M:set_text(text)
	return self:set_to(text)
end

---通过语言环境ID翻译文本。当语言环境更改时，文本将自动更新。
---此函数是实现动态文本本地化的核心方法，支持参数格式化
---@param locale_id string 获取文本的语言环境ID
---@param ... string string.format的可选参数
---@return druid.lang_text self 当前实例
function M:translate(locale_id, ...)
	self.last_locale_args = { ... }
	self.last_locale = locale_id or self.last_locale
	self.text:set_text(settings.get_text(self.last_locale, ...) or "")

	return self
end

---使用新文本参数格式化本地化文本。保持当前语言环境但更新格式参数。
---此函数允许在不改变语言环境的情况下更新文本的格式化参数
---@param ... string string.format的可选参数
---@return druid.lang_text self 当前实例
function M:format(...)
	self.last_locale_args = { ... }
	self.text:set_text(settings.get_text(self.last_locale, ...) or "")

	return self
end

return M
