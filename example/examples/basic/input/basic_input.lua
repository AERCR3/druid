--- 输入框示例：展示输入框的选中/取消选中事件处理和自定义样式
---@class examples.basic_input: druid.widget
---@field input druid.input
local M = {}

--- 选中状态下的文本颜色（白色）
local COLOR_SELECTED = vmath.vector3(1, 1, 1)
--- 未选中状态下的文本颜色（灰色）
local COLOR_UNSELECTED = vmath.vector3(184 / 255, 189 / 255, 194 / 255)

--- 初始化函数：创建两个输入框，设置选中和取消选中时的颜色变化
---@param template string 模板名称
---@param nodes table<hash, node> 节点表
function M:init(template, nodes)
	self.druid = self:get_druid(template, nodes)

	self.input = self.druid:new_input("input/root", "input/text")
	self.input.on_input_select:subscribe(function()
		gui.set_color(self.input.text.node, COLOR_SELECTED)
	end)
	self.input.on_input_unselect:subscribe(function(_, text)
		-- 当输入框取消选中时，打印用户输入的文本
		print("用户输入的文本: " .. text)
		gui.set_color(self.input.text.node, COLOR_UNSELECTED)
	end)

	self.input_2 = self.druid:new_input("input_2/root", "input_2/text")
	self.input_2:set_text("")
	self.input_2.on_input_select:subscribe(function()
		gui.set_color(self.input_2.text.node, COLOR_SELECTED)
	end)
	self.input_2.on_input_unselect:subscribe(function(_, text)
		-- 当第二个输入框取消选中时，打印用户输入的文本
		print("用户输入的文本: " .. text)
		gui.set_color(self.input_2.text.node, COLOR_UNSELECTED)
	end)

	-- 可以为 input 及其内部组件设置自定义 style
	-- 本示例中：长按下方输入框会清空文本（通过 style 开关实现）
	self.input_2.style.IS_LONGTAP_ERASE = true
	self.input_2.button.style.AUTOHOLD_TRIGGER = 1.5
end

---@param output_log output_list
function M:on_example_created(output_log)
	-- 订阅第一个输入框的选中事件
	self.input.on_input_select:subscribe(function()
		output_log:add_log_text("输入框已选中")
	end)
	-- 订阅第二个输入框的选中事件
	self.input_2.on_input_select:subscribe(function()
		output_log:add_log_text("输入框2已选中")
	end)
	-- 订阅第一个输入框的取消选中事件，并记录文本内容
	self.input.on_input_unselect:subscribe(function(_, text)
		output_log:add_log_text("输入框已取消选中。文本: " .. text)
	end)
	-- 订阅第二个输入框的取消选中事件，并记录文本内容
	self.input_2.on_input_unselect:subscribe(function(_, text)
		output_log:add_log_text("输入框已取消选中。文本: " .. text)
	end)
end

return M
