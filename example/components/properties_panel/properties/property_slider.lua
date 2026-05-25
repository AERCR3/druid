---@class property_slider: druid.widget
---@field root druid.container
---@field text_name druid.lang_text
---@field text_value druid.text
---@field slider druid.slider
local M = {}


--- 初始化函数：创建滑块控件、文本标签和值显示
function M:init()
	self.root = self.druid:new_container("root") --[[@as druid.container]]
	self.selected = self:get_node("selected")
	gui.set_alpha(self.selected, 0)
	self._value = 0

	self.text_name = self.druid:new_lang_text("text_name") --[[@as druid.lang_text]]
	self.text_value = self.druid:new_text("text_value")
	self.slider = self.druid:new_slider("slider_pin", vmath.vector3(68, 0, 0), self._on_slider_change_by_user) --[[@as druid.slider]]
	self.slider:set_input_node("slider")

	self:set_text_function(function(value)
		return math.floor(value * 100) .. "%"
	end)
end

--- 设置文本格式化函数：自定义滑块值的显示格式
---@param callback fun(value:number):string 格式化回调函数
function M:set_text_function(callback)
	self._text_function = callback
	self.text_value:set_text(self._text_function(self._value))
end

--- 设置滑块值：更新滑块位置和文本显示，可选择是否显示动画效果
---@param value number 滑块值（0-1）
---@param is_instant boolean 是否立即设置（无动画）
function M:set_value(value, is_instant)
	if self._value == value then
		return
	end

	self._value = value
	self.slider:set(value, true)
	self.text_value:set_text(self._text_function(value))

	if not is_instant then
		gui.set_alpha(self.selected, 1)
		gui.animate(self.selected, "color.w", 0, gui.EASING_INSINE, 0.16)
	end
end

--- 获取当前滑块值
---@return number 当前滑块值（0-1）
function M:get_value()
	return self._value
end

--- 用户拖拽滑块回调：更新值和文本显示，播放选中动画
---@param value number 拖拽后的值
function M:_on_slider_change_by_user(value)
	self._value = value
	self.text_value:set_text(self._text_function(value))

	gui.set_alpha(self.selected, 1)
	gui.animate(self.selected, "color.w", 0, gui.EASING_INSINE, 0.16)
end

return M
