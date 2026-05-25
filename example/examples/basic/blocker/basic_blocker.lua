---@class examples.basic_blocker: druid.widget
---@field root node
---@field blocker druid.blocker
local M = {}


function M:init()
	self.root = self:get_node("root")

	self.button_root = self.druid:new_button(self.root, self.on_root_click)
	-- blocker 会拦截指定区域内的输入事件，阻止事件继续传递到其下层/后面的节点
	self.blocker = self.druid:new_blocker("blocker")
	self.button = self.druid:new_button("button/root", self.on_button_click)
end


function M:on_root_click()
	print("Root click")
end


function M:on_button_click()
	print("Button click")
end


---@param output_log output_list
function M:on_example_created(output_log)
	self.button_root.on_click:subscribe(function()
		output_log:add_log_text("Root Clicked")
	end)
	self.button.on_click:subscribe(function()
		output_log:add_log_text("Button Clicked")
	end)
end


return M
