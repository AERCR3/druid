return function()
	-- 测试Druid实例的功能
	describe("Druid Instance", function()
		local druid
		local druid_instance ---@type druid.instance
		local context
		local mock_input = require("test.helper.mock_input")

		-- 初始化测试环境
		before(function()
			context = vmath.vector3()
			druid = require("druid.druid")
			druid_instance = druid.new(context)
		end)

		-- 清理测试环境
		after(function()
			-- 清理druid实例
			if druid_instance then
				druid_instance:final()
				druid_instance = nil
			end
		end)

		-- 测试按钮组件的创建和功能
		it("Should create button component", function()
			local button_node = gui.new_box_node(vmath.vector3(50, 25, 0), vmath.vector3(100, 50, 0))

			local on_click_calls = 0
			local function on_click()
				on_click_calls = on_click_calls + 1
			end

			local button = druid_instance:new_button(button_node, on_click)

			assert(button ~= nil)
			assert(button.node == button_node)

			-- 测试按钮点击是否有效
			druid_instance:on_input(mock_input.click_pressed(50, 25))
			druid_instance:on_input(mock_input.click_released(50, 25))

			assert(on_click_calls == 1)

			-- 清理组件
			druid_instance:remove(button)
			gui.delete_node(button_node)
		end)

		-- 测试拦截器组件的创建和功能
		it("Should create blocker component", function()
			local blocker_node = gui.new_box_node(vmath.vector3(100, 50, 0), vmath.vector3(200, 100, 0))

			local blocker = druid_instance:new_blocker(blocker_node)

			assert(blocker ~= nil)
			assert(blocker.node == blocker_node)

			-- 测试拦截器是否能够拦截输入
			local is_blocked = druid_instance:on_input(mock_input.click_pressed(100, 50))

			assert(is_blocked)

			-- 清理组件
			druid_instance:remove(blocker)
			gui.delete_node(blocker_node)
		end)

		-- 测试返回键处理器组件的创建和功能
		it("Should create back_handler component", function()
			local on_back_calls = 0
			local function on_back()
				on_back_calls = on_back_calls + 1
			end

			local back_handler = druid_instance:new_back_handler(on_back)

			assert(back_handler ~= nil)

			-- 测试返回键处理器是否有效
			druid_instance:on_input(mock_input.key_pressed("key_back"))
			druid_instance:on_input(mock_input.key_released("key_back"))

			assert(on_back_calls == 1)

			-- 清理组件
			druid_instance:remove(back_handler)
		end)

		-- 测试悬停组件的创建和功能
		it("Should create hover component", function()
			local button_node = gui.new_box_node(vmath.vector3(50, 25, 0), vmath.vector3(100, 50, 0))

			local on_hover_calls = 0
			local function on_hover()
				on_hover_calls = on_hover_calls + 1
			end

			local hover = druid_instance:new_hover(button_node, on_hover)

			assert(hover ~= nil)
			assert(hover.node == button_node)

			-- 测试悬停功能是否有效
			druid_instance:on_input(mock_input.input_empty(50, 25))

			assert(on_hover_calls == 1)

			-- 清理组件
			druid_instance:remove(hover)
			gui.delete_node(button_node)
		end)

		-- 测试文本组件的创建和功能
		it("Should create text component", function()
			local text_node = gui.new_text_node(vmath.vector3(50, 25, 0), "Test Text")
			gui.set_font(text_node, "druid_text_bold")

			local text = druid_instance:new_text(text_node, "New Text")

			assert(text ~= nil)
			assert(text.node == text_node)
			assert(gui.get_text(text_node) == "New Text")

			-- 测试文本设置器是否有效
			text:set_text("Updated Text")
			assert(gui.get_text(text_node) == "Updated Text")

			-- 清理组件
			druid_instance:remove(text)
			gui.delete_node(text_node)
		end)

		-- 测试网格组件的创建和功能
		it("Should create grid component", function()
			local parent_node = gui.new_box_node(vmath.vector3(150, 100, 0), vmath.vector3(300, 200, 0))
			local template = gui.new_box_node(vmath.vector3(10, 10, 0), vmath.vector3(20, 20, 0))

			local grid = druid_instance:new_grid(parent_node, template, 3)

			assert(grid ~= nil)
			assert(grid.parent == parent_node)
			assert(grid.in_row == 3)

			-- 向网格中添加一个项目
			local item = gui.clone(template)
			grid:add(item)
			assert(#grid.nodes == 1)

			-- 清理组件
			druid_instance:remove(grid)
			gui.delete_node(parent_node)
			gui.delete_node(template)
		end)

		-- 测试滚动组件的创建和功能
		it("Should create scroll component", function()
			local parent_node = gui.new_box_node(vmath.vector3(150, 100, 0), vmath.vector3(300, 200, 0))
			local content_node = gui.new_box_node(vmath.vector3(250, 200, 0), vmath.vector3(500, 400, 0))

			-- 设置滚动的节点层级关系
			gui.set_parent(content_node, parent_node)

			local scroll = druid_instance:new_scroll(parent_node, content_node)

			assert(scroll ~= nil)
			assert(scroll.view_node == parent_node)
			assert(scroll.content_node == content_node)

			-- 测试滚动设置器是否有效
			scroll:set_horizontal_scroll(true)

			-- 清理组件
			druid_instance:remove(scroll)
			gui.delete_node(parent_node) -- 这也会删除content_node，因为它是子节点
		end)

		-- 测试拖拽组件的创建和功能
		it("Should create drag component", function()
			local button_node = gui.new_box_node(vmath.vector3(50, 25, 0), vmath.vector3(100, 50, 0))

			local on_drag_calls = 0
			local drag_dx, drag_dy

			local function on_drag(_, dx, dy)
				on_drag_calls = on_drag_calls + 1
				drag_dx, drag_dy = dx, dy
			end

			local drag = druid_instance:new_drag(button_node, on_drag)
			drag.style.DRAG_DEADZONE = 0
			drag.style.NO_USE_SCREEN_KOEF = true

			assert(drag ~= nil)
			assert(drag.node == button_node)

			-- 测试拖拽回调函数是否有效
			druid_instance:on_input(mock_input.click_pressed(50, 25))
			druid_instance:on_input(mock_input.input_empty(60, 35))
			druid_instance:on_input(mock_input.click_released(60, 35))

			assert(on_drag_calls == 1)
			assert(math.floor(drag_dx) == 10)
			assert(math.floor(drag_dy) == 10)

			-- 清理组件
			druid_instance:remove(drag)
			gui.delete_node(button_node)
		end)

		-- 测试滑动组件的创建和功能
		it("Should create swipe component", function()
			local button_node = gui.new_box_node(vmath.vector3(50, 25, 0), vmath.vector3(100, 50, 0))

			local on_swipe_calls = 0
			local function on_swipe()
				on_swipe_calls = on_swipe_calls + 1
			end

			local swipe = druid_instance:new_swipe(button_node, on_swipe)

			assert(swipe ~= nil)
			assert(swipe.node == button_node)

			-- 清理组件
			druid_instance:remove(swipe)
			gui.delete_node(button_node)
		end)

		-- 测试计时器组件的创建和功能
		it("Should create timer component", function()
			local text_node = gui.new_text_node(vmath.vector3(50, 25, 0), "Test Text")
			gui.set_font(text_node, "druid_text_bold")

			local on_timer_end_calls = 0
			local function on_timer_end()
				on_timer_end_calls = on_timer_end_calls + 1
			end

			local timer = druid_instance:new_timer(text_node, 10, 0, on_timer_end)

			assert(timer ~= nil)
			assert(timer.node == text_node)

			-- 清理组件
			druid_instance:remove(timer)
			gui.delete_node(text_node)
		end)

		it("Should create progress component", function()
			local button_node = gui.new_box_node(vmath.vector3(50, 25, 0), vmath.vector3(100, 50, 0))

			local progress = druid_instance:new_progress(button_node, "x", 0.5)

			assert(progress ~= nil)
			assert(progress.node == button_node)
			assert(progress:get() == 0.5)

			-- Test that progress setter works
			progress:set_to(0.75)
			assert(progress:get() == 0.75)

			-- Clean up component
			druid_instance:remove(progress)
			gui.delete_node(button_node)
		end)

		it("Should create layout component", function()
			local parent_node = gui.new_box_node(vmath.vector3(150, 100, 0), vmath.vector3(300, 200, 0))

			local layout = druid_instance:new_layout(parent_node)

			assert(layout ~= nil)
			assert(layout.node == parent_node)

			-- Clean up component
			druid_instance:remove(layout)
			gui.delete_node(parent_node)
		end)

		it("Should create hotkey component", function()
			local on_hotkey_calls = 0
			local function on_hotkey()
				on_hotkey_calls = on_hotkey_calls + 1
			end

			local hotkey = druid_instance:new_hotkey("key_f", on_hotkey)

			assert(hotkey ~= nil)

			-- Test that hotkey works
			druid_instance:on_input(mock_input.key_pressed("key_f"))
			druid_instance:on_input(mock_input.key_released("key_f"))

			assert(on_hotkey_calls == 1)

			-- Clean up component
			druid_instance:remove(hotkey)
		end)

		it("Should create container component", function()
			local parent_node = gui.new_box_node(vmath.vector3(150, 100, 0), vmath.vector3(300, 200, 0))

			local layout_changed_calls = 0
			local function layout_changed()
				layout_changed_calls = layout_changed_calls + 1
			end

			-- The container component requires a node with size
			local container = druid_instance:new_container(parent_node, "fit")

			assert(container ~= nil)

			-- Clean up component
			druid_instance:remove(container)
			gui.delete_node(parent_node)
		end)
	end)
end
