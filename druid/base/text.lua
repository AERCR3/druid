local event = require("event.event")
local const = require("druid.const")
local helper = require("druid.helper")
local utf8_lua = require("druid.system.utf8")
local component = require("druid.component")
local utf8 = utf8 or utf8_lua --[[@as utf8]]

---@class druid.text.style
---@field TRIM_POSTFIX string|nil TRIM调整类型的后缀。默认值: ...
---@field DEFAULT_ADJUST string|nil 任何文本组件的默认调整类型。默认值: DOWNSCALE
---@field ADJUST_STEPS number|nil 按高度调整文本的迭代次数。默认值: 20
---@field ADJUST_SCALE_DELTA number|nil 每个高度调整步骤的缩放步长。默认值: 0.02

---@alias druid.text.adjust_type "downscale"|"trim"|"no_adjust"|"downscale_limited"|"scroll"|"scale_then_scroll"|"trim_left"|"scale_then_trim"|"scale_then_trim_left"

---基本的Druid文本组件
---文本组件提供了丰富的文本显示和自动调整功能，支持多种文本适应策略
---此组件是UI开发中最常用的基础组件之一，为用户界面提供灵活的文本处理能力
---
---### 设置方法
---使用druid创建文本节点：`text = druid:new_text(node_name, [initial_value], [text_adjust_type])`
--- node_name是GUI场景中的文本节点名称
--- initial_value是可选的初始文本内容
--- text_adjust_type是文本调整类型（可选）
---
---### 主要特性
---- 文本组件默认具有自动调整文本大小功能，确保文本不会超出节点边界
---- 文本枢轴点可以通过`text:set_pivot`动态更改，文本会在其尺寸框内保持位置
---- 支持多种文本调整策略，适应不同的UI需求
---
---### 文本调整类型详解
----   - **"downscale"** - 缩放文本以适应文本节点大小（默认策略）
----   - **"trim"** - 用后缀（默认为"..."）修剪文本以适配节点宽度
----   - **"no_adjust"** - 不进行任何调整，保持Defold默认文本行为
----   - **"downscale_limited"** - 缩放文本但有缩放限制，防止文本过小
----   - **"scroll"** - 通过更改文本枢轴点来模拟文本滚动效果，配合遮罩使用更佳
----   - **"scale_then_scroll"** - 组合模式：先有限缩放，再滚动
----   - **"trim_left"** - 从左边开始修剪文本，保持右边内容完整
----   - **"scale_then_trim"** - 组合模式：先有限缩放，再修剪
----   - **"scale_then_trim_left"** - 组合模式：先有限缩放，再从左边修剪
---@class druid.text: druid.component
---@field node node 文本节点
---@field on_set_text event fun(self: druid.text, text: string) 设置文本时触发的事件
---@field on_update_text_scale event fun(self: druid.text, scale: vector3, metrics: table) 更新文本缩放时触发的事件
---@field on_set_pivot event fun(self: druid.text, pivot: userdata) 设置文本枢轴点时触发的事件
---@field style druid.text.style 文本的样式
---@field start_pivot number 文本的起始枢轴点
---@field start_scale vector3 文本的起始缩放
---@field scale vector3 文本的当前缩放
local M = component.create("text")


---文本组件的构造函数
---初始化文本实例，设置节点、初始文本值、调整类型和相关事件
---这是使用文本组件时调用的第一个方法，完成基础配置
---@param node string|node GUI场景中的文本节点名称或节点对象
--- 用于指定文本组件要操作的GUI文本节点
---@param value string|nil 初始文本内容
--- 如果提供，将使用此值作为文本内容
--- 如果为nil，则从GUI场景中获取节点的默认文本
---@param adjust_type druid.text.adjust_type|nil 文本的调整类型
--- 指定文本如何适应其容器的大小
--- 可选值："downscale", "trim", "no_adjust", "downscale_limited", "scroll", "scale_then_scroll", "trim_left", "scale_then_trim", "scale_then_trim_left"
function M:init(node, value, adjust_type)
	--- 获取文本节点及其基本信息
	self.node = self:get_node(node)
	self.pos = gui.get_position(self.node)
	self.node_id = gui.get_id(self.node)

	--- 保存文本节点的初始状态，用于后续调整和恢复
	self.start_pivot = gui.get_pivot(self.node)
	self.start_scale = gui.get_scale(self.node)
	self.scale = gui.get_scale(self.node)

	--- 获取文本的尺寸信息，用于文本调整计算
	self.start_size = gui.get_size(self.node)
	self.text_area = gui.get_size(self.node)
	--- 考虑缩放因素的文本区域大小
	self.text_area.x = self.text_area.x * self.start_scale.x
	self.text_area.y = self.text_area.y * self.start_scale.y

	--- 设置文本调整类型，如果未提供则使用默认的"downscale"策略
	self.adjust_text_type = adjust_type or self.style.DEFAULT_ADJUST
	--- 保存文本的当前颜色状态
	self.color = gui.get_color(self.node)

	--- 创建文本相关的事件，用于监听文本变化和调整事件
	self.on_set_text = event.create()         -- 文本设置时触发
	self.on_set_pivot = event.create()        -- 枢轴点设置时触发
	self.on_update_text_scale = event.create() -- 文本缩放更新时触发

	--- 设置初始文本内容，如果value为nil则从GUI场景获取
	self:set_text(value or gui.get_text(self.node))
end

---私有方法：处理文本样式变化
---当文本组件的样式配置发生改变时调用此方法，更新样式参数
---@private
---@param style druid.text.style 新的样式配置表
--- 包含文本调整的各种参数设置
function M:on_style_change(style)
	--- 合并用户自定义样式与默认样式
	self.style = {
		--- 修剪文本时使用的后缀字符串，默认为"..."
		TRIM_POSTFIX = style.TRIM_POSTFIX or "...",
		--- 文本组件的默认调整类型，默认为"downscale"（缩放适配）
		DEFAULT_ADJUST = style.DEFAULT_ADJUST or "downscale",
		--- 按高度调整文本时的迭代次数，用于逐步逼近合适的缩放比例
		ADJUST_STEPS = style.ADJUST_STEPS or 20,
		--- 每个高度调整步骤的缩放步长，控制调整的精度
		ADJUST_SCALE_DELTA = style.ADJUST_SCALE_DELTA or 0.02
	}
end

---私有方法：处理布局变化
---当GUI布局发生变化时调用此方法，重新应用文本调整
---这确保了文本在布局变化后仍然能正确适配新的容器尺寸
---@private
function M:on_layout_change()
	--- 使用最后保存的文本值重新设置文本
	--- 这会触发文本调整逻辑，确保文本在新布局中仍然适配
	self:set_text(self.last_value)
end

---计算文本的精确尺寸
---根据当前字体设置和节点配置计算文本的宽度和高度
---此函数考虑了文本缩放、换行设置等因素，提供准确的文本尺寸测量
---@param text string|nil 要计算大小的文本
--- 如果为nil，则使用当前文本组件的文本内容
---@return number width 文本宽度（考虑缩放因子后的实际像素宽度）
---@return number height 文本高度（考虑缩放因子后的实际像素高度）
function M:get_text_size(text)
	--- 确定要计算的文本内容
	text = text or self.last_value
	--- 获取文本节点使用的字体名称
	local font_name = gui.get_font(self.node)
	--- 获取字体资源对象，用于文本尺寸计算
	local font = gui.get_font_resource(font_name)
	--- 获取文本的缩放比例，如果没有记录则从节点获取
	local scale = self.last_scale or gui.get_scale(self.node)
	--- 获取文本的换行设置，影响多行文本的布局
	local linebreak = gui.get_line_break(self.node)

	--- 计算字符"."的宽度，用于后续的宽度调整
	--- 使用点字符是因为它的宽度通常代表一个字符的平均宽度
	local dot_width = resource.get_text_metrics(font, ".").width

	--- 获取文本的渲染指标，包括宽度、高度等
	--- 在文本末尾添加一个点字符，便于计算准确宽度
	local metrics = resource.get_text_metrics(font, text .. ".", {
		line_break = linebreak, -- 使用节点的换行设置
		leading = 1,            -- 行间距倍数
		tracking = 0,           -- 字符间距
		width = self.start_size.x -- 最大宽度限制
	})

	--- 从总宽度中减去点字符的宽度，得到实际文本宽度
	--- 这是修正测量误差的方法
	local width = metrics.width - dot_width
	--- 返回考虑缩放因子的实际尺寸
	return width * scale.x, metrics.height * scale.y
end

---根据宽度获取字符数量
---@param width number 要获取字符数的宽度
---@return number index 字符数量
function M:get_text_index_by_width(width)
	local text = self.last_value
	local font_name = gui.get_font(self.node)
	local font = gui.get_font_resource(font_name)
	local scale = self.last_scale or gui.get_scale(self.node)

	local text_index = 0
	local text_width = 0
	local text_length = utf8.len(text)
	local dot_width = resource.get_text_metrics(font, ".").width
	local previous_width = 0
	for i = 1, text_length do
		local subtext = utf8.sub(text, 1, i) .. "."
		local subtext_width = resource.get_text_metrics(font, subtext).width
		subtext_width = subtext_width - dot_width
		text_width = subtext_width * scale.x
		local width_delta = text_width - previous_width
		previous_width = text_width

		if (text_width - width_delta / 2) < width then
			text_index = i
		else
			break
		end
	end

	return text_index
end

---设置文本字段文本
---@deprecated
---@param set_to string 节点文本
---@return druid.text self 当前文本实例
function M:set_to(set_to)
	set_to = tostring(set_to or "")

	self.last_value = set_to
	gui.set_text(self.node, set_to)

	self.on_set_text:trigger(self:get_context(), set_to)

	self:_update_adjust()

	return self
end

function M:set_text(new_text)
	---@diagnostic disable-next-line: deprecated
	return self:set_to(new_text)
end

function M:get_text()
	return self.last_value
end

---设置文本区域大小
---@param size vector3 新的文本区域大小
---@return druid.text self 当前文本实例
function M:set_size(size)
	self.start_size = size
	self.text_area = vmath.vector3(size)
	self.text_area.x = self.text_area.x * self.start_scale.x
	self.text_area.y = self.text_area.y * self.start_scale.y
	self:_update_adjust()

	return self
end

---设置颜色
---@param color vector4 节点颜色
---@return druid.text self 当前文本实例
function M:set_color(color)
	self.color = color
	gui.set_color(self.node, color)

	return self
end

---设置透明度
---@param alpha number 节点透明度
---@return druid.text self 当前文本实例
function M:set_alpha(alpha)
	self.color.w = alpha
	gui.set_color(self.node, self.color)

	return self
end

---设置缩放
---@param scale vector3 节点缩放
---@return druid.text self 当前文本实例
function M:set_scale(scale)
	self.last_scale = scale
	gui.set_scale(self.node, scale)

	return self
end

---设置文本枢轴点。文本将在其文本区域内重新锚定
---@param pivot number gui.PIVOT_*常量
---@return druid.text self 当前文本实例
function M:set_pivot(pivot)
	local prev_pivot = gui.get_pivot(self.node)
	local prev_offset = const.PIVOTS[prev_pivot]

	gui.set_pivot(self.node, pivot)
	local cur_offset = const.PIVOTS[pivot]

	local pos_offset = vmath.vector3(
		self.text_area.x * (cur_offset.x - prev_offset.x),
		self.text_area.y * (cur_offset.y - prev_offset.y),
		0
	)

	self.pos = self.pos + pos_offset
	gui.set_position(self.node, self.pos)

	self.on_set_pivot:trigger(self:get_context(), pivot)

	return self
end

---如果文本有换行符则返回true
---@return boolean 文本节点是否有换行符
function M:is_multiline()
	return gui.get_line_break(self.node)
end

---设置文本调整，如果需要则刷新当前文本视觉效果
---@param adjust_type druid.text.adjust_type|nil 要设置的调整类型，值："downscale", "trim", "no_adjust", "downscale_limited", "scroll", "scale_then_scroll", "trim_left", "scale_then_trim", "scale_then_trim_left"
---@param minimal_scale number|nil 要移除最小缩放，使用`text:set_minimal_scale(nil)`，如果传递nil - 不更改最小缩放
---@return druid.text self 当前文本实例
function M:set_text_adjust(adjust_type, minimal_scale)
	self.adjust_type = adjust_type
	self._minimal_scale = minimal_scale or self._minimal_scale
	self:set_text(self.last_value)

	return self
end

---为"downscale_limited"或"scale_then_scroll"调整类型设置最小缩放
---@param minimal_scale number 如果传递nil - 不使用最小缩放
---@return druid.text self 当前文本实例
function M:set_minimal_scale(minimal_scale)
	self._minimal_scale = minimal_scale

	return self
end

---返回当前文本调整类型
---@return string adjust_type 当前的文本调整类型
function M:get_text_adjust()
	return self.adjust_type
end

---@private
function M:_update_text_size()
	if self.scale.x == 0 or self.scale.y == 0 then
		return
	end
	if self.start_scale.x == 0 or self.start_scale.y == 0 then
		return
	end

	local size = vmath.vector3(
		self.start_size.x * (self.start_scale.x / self.scale.x),
		self.start_size.y * (self.start_scale.y / self.scale.y),
		self.start_size.z
	)
	gui.set_size(self.node, size)
end

---重置文本的初始缩放
---@private
function M:_reset_default_scale()
	self.scale.x = self.start_scale.x
	self.scale.y = self.start_scale.y
	self.scale.z = self.start_scale.z
	gui.set_scale(self.node, self.start_scale)
	gui.set_size(self.node, self.start_size)
end

---@private
---@param metrics table
---@return boolean
function M:_is_fit_info_area(metrics)
	return metrics.width * self.scale.x <= self.text_area.x and
			metrics.height * self.scale.y <= self.text_area.y
end

---Setup scale x, but can only be smaller, than start text scale
---@private
function M:_update_text_area_size()
	self:_reset_default_scale()

	local metrics = helper.get_text_metrics_from_node(self.node)

	if metrics.width == 0 then
		self:_reset_default_scale()
		self.on_update_text_scale:trigger(self:get_context(), self.start_scale, metrics)
		return
	end

	local text_area_width = self.text_area.x
	local text_area_height = self.text_area.y

	-- Adjust by width
	local scale_modifier = text_area_width / metrics.width

	-- Adjust by height
	if self:is_multiline() then
		-- Approximate scale by height to start adjust scale
		scale_modifier = math.sqrt(text_area_height / metrics.height)
		if metrics.width * scale_modifier > text_area_width then
			scale_modifier = text_area_width / metrics.width
		end

		-- #RMME
		if self._minimal_scale then
			scale_modifier = math.max(scale_modifier, self._minimal_scale)
		end
		-- Limit max scale by initial scale
		scale_modifier = math.min(scale_modifier, self.start_scale.x)
		-- #RMME

		local is_fit = self:_is_fit_info_area(metrics)
		local step = is_fit and self.style.ADJUST_SCALE_DELTA or -self.style.ADJUST_SCALE_DELTA

		for i = 1, self.style.ADJUST_STEPS do
			-- Grow down to check if we fit
			if step < 0 and is_fit then
				break
			end
			-- Grow up to check if we still fit
			if step > 0 and not is_fit then
				break
			end

			scale_modifier = scale_modifier + step

			if self._minimal_scale then
				scale_modifier = math.max(scale_modifier, self._minimal_scale)
			end
			-- Limit max scale by initial scale
			scale_modifier = math.min(scale_modifier, self.start_scale.x)

			self.scale.x = scale_modifier
			self.scale.y = scale_modifier
			self.scale.z = self.start_scale.z
			gui.set_scale(self.node, self.scale)
			self:_update_text_size()
			metrics = helper.get_text_metrics_from_node(self.node)
			is_fit = self:_is_fit_info_area(metrics)
		end
	end

	if self._minimal_scale then
		scale_modifier = math.max(scale_modifier, self._minimal_scale)
	end

	-- Limit max scale by initial scale
	scale_modifier = math.min(scale_modifier, self.start_scale.x)

	self.scale.x = scale_modifier
	self.scale.y = scale_modifier
	self.scale.z = self.start_scale.z
	gui.set_scale(self.node, self.scale)
	self:_update_text_size()

	self.on_update_text_scale:trigger(self:get_context(), self.scale, metrics)
end

---@private
---@param trim_postfix string
function M:_update_text_with_trim(trim_postfix)
	local max_width = self.text_area.x
	local text_width = self:get_text_size()

	if text_width > max_width then
		local text_length = utf8.len(self.last_value)
		local new_text = self.last_value
		while text_width > max_width do
			text_length = text_length - 1
			new_text = utf8.sub(self.last_value, 1, text_length)
			text_width = self:get_text_size(new_text .. trim_postfix)
			if text_length == 0 then
				break
			end
		end

		gui.set_text(self.node, new_text .. trim_postfix)
	else
		gui.set_text(self.node, self.last_value)
	end
end

---@private
---@param trim_postfix string
function M:_update_text_with_trim_left(trim_postfix)
	local max_width = self.text_area.x
	local text_width = self:get_text_size()
	local text_length = utf8.len(self.last_value)
	local trim_index = 1

	if text_width > max_width then
		local new_text = self.last_value
		while text_width > max_width and trim_index < text_length do
			trim_index = trim_index + 1
			new_text = trim_postfix .. utf8.sub(self.last_value, trim_index, text_length)
			text_width = self:get_text_size(new_text)
		end

		gui.set_text(self.node, new_text)
	end
end

---@private
function M:_update_text_with_anchor_shift()
	if self:get_text_size() >= self.text_area.x then
		self:set_pivot(const.REVERSE_PIVOTS[self.start_pivot])
	else
		self:set_pivot(self.start_pivot)
	end
end

---@private
function M:_update_adjust()
	if not self.adjust_type or self.adjust_type == "no_adjust" then
		self:_reset_default_scale()
		return
	end

	if self.adjust_type == "downscale" then
		self:_update_text_area_size()
	end

	if self.adjust_type == "trim" then
		self:_update_text_with_trim(self.style.TRIM_POSTFIX)
	end

	if self.adjust_type == "trim_left" then
		self:_update_text_with_trim_left(self.style.TRIM_POSTFIX)
	end

	if self.adjust_type == "downscale_limited" then
		self:_update_text_area_size()
	end

	if self.adjust_type == "scroll" then
		self:_update_text_with_anchor_shift()
	end

	if self.adjust_type == "scale_then_scroll" then
		self:_update_text_area_size()
		self:_update_text_with_anchor_shift()
	end

	if self.adjust_type == "scale_then_trim" then
		self:_update_text_area_size()
		self:_update_text_with_trim(self.style.TRIM_POSTFIX)
	end

	if self.adjust_type == "scale_then_trim_left" then
		self:_update_text_area_size()
		self:_update_text_with_trim_left(self.style.TRIM_POSTFIX)
	end
end

return M
