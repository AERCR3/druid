local helper = require("druid.helper")
local component = require("druid.component")
local rich_text = require("druid.custom.rich_text.module.rt")

local VECTOR3_ONE = vmath.vector3(1)

---@class druid.rich_text.settings
---@field parent node
---@field size number
---@field fonts table<string, string>
---@field scale vector3
---@field color vector4
---@field shadow vector4
---@field outline vector4
---@field position vector3
---@field image_pixel_grid_snap boolean
---@field combine_words boolean
---@field default_animation string
---@field split_by_character boolean
---@field text_prefab node
---@field adjust_scale number
---@field default_texture string
---@field is_multiline boolean
---@field text_leading number
---@field font hash
---@field width number
---@field height number

---@class druid.rich_text.word
---@field node node
---@field relative_scale number
---@field source_text string
---@field color vector4
---@field text_color vector4
---@field position vector3
---@field offset vector3
---@field scale vector3
---@field size vector3
---@field metrics druid.rich_text.metrics
---@field pivot constant
---@field text string
---@field shadow vector4
---@field outline vector4
---@field font string
---@field image druid.rich_text.word.image
---@field br boolean
---@field nobr boolean
---@field tags table<string, boolean>

---@class druid.rich_text.word.image
---@field texture string
---@field anim string
---@field width number
---@field height number

---@class druid.rich_text.style
---@field ADJUST_STEPS number
---@field ADJUST_SCALE_DELTA number

---@class druid.rich_text.lines_metrics
---@field text_width number
---@field text_height number
---@field lines table<number, druid.rich_text.metrics>

---@class druid.rich_text.metrics
---@field width number
---@field height number
---@field offset_x number|nil
---@field offset_y number|nil
---@field node_size vector3|nil

---处理富文本显示的组件，允许自定义文本各部分的颜色、大小、字体等
---@class druid.rich_text: druid.component
---@field root node 富文本的根文本节点
---@field text_prefab node 文本预制节点
---@field private _last_value string 富文本的最后一个值
---@field private _settings table 富文本的设置
---@field private _split_to_characters boolean 分割为字符的标志
---@field private _anchor vector3|nil 锚点位置（当设置枢轴时，在调整大小时保持内容位置）
local M = component.create("rich_text")


---@param text_node node|string 要制作富文本的文本节点
---@param value string|nil 初始文本值。默认为gui.get_text(text_node)
function M:init(text_node, value)
	self.root = self:get_node(text_node)
	self.text_prefab = self.root

	self._last_value = value or gui.get_text(self.text_prefab)
	self._settings = self:_create_settings()
	self._split_to_characters = false

	gui.set_text(self.root, "")

	if value then
		self:set_text(value)
	end
end

---@private
function M:on_layout_change()
	gui.set_text(self.root, "")
	self._settings = self:_create_settings()

	if self._last_value then
		self:set_text(self._last_value)
	end
end

---@private
---@param style druid.rich_text.style 富文本样式
function M:on_style_change(style)
	self.style = {
		ADJUST_STEPS = style.ADJUST_STEPS or 20,
		ADJUST_SCALE_DELTA = style.ADJUST_SCALE_DELTA or 0.02,
	}
end

---为富文本设置文本
---		-- Color
---		rich_text:set_text("＜color=red＞Foobar＜/color＞")
---		rich_text:set_text("＜color=1.0,0,0,1.0＞Foobar＜/color＞")
---		rich_text:set_text("＜color=#ff0000＞Foobar＜/color＞")
---		rich_text:set_text("＜color=#ff0000ff＞Foobar＜/color＞")
---		-- Shadow
---		rich_text:set_text("＜shadow=red＞Foobar＜/shadow＞")
---		rich_text:set_text("＜shadow=1.0,0,0,1.0＞Foobar＜/shadow＞")
---		rich_text:set_text("＜shadow=#ff0000＞Foobar＜/shadow＞")
---		rich_text:set_text("＜shadow=#ff0000ff＞Foobar＜/shadow＞")
---		-- Outline
---		rich_text:set_text("＜outline=red＞Foobar＜/outline＞")
---		rich_text:set_text("＜outline=1.0,0,0,1.0＞Foobar＜/outline＞")
---		rich_text:set_text("＜outline=#ff0000＞Foobar＜/outline＞")
---		rich_text:set_text("＜outline=#ff0000ff＞Foobar＜/outline＞")
---		-- Font
---		rich_text:set_text("＜font=MyCoolFont＞Foobar＜/font＞")
---		-- Size
---		rich_text:set_text("＜size=2＞Twice as large＜/size＞")
---		-- Line break
---		rich_text:set_text("＜br/＞Insert a line break")
---		-- No break
---		rich_text:set_text("＜nobr＞Prevent the text from breaking")
---		-- Image
---		rich_text:set_text("＜img=texture:image＞Display image")
---		rich_text:set_text("＜img=texture:image,size＞Display image with size")
---		rich_text:set_text("＜img=texture:image,width,height＞Display image with width and height")
---@param text string|nil The text to set
---@return druid.rich_text.word[] words
---@return druid.rich_text.lines_metrics line_metrics
function M:set_text(text)
	text = text or ""
	self:clear()
	self._last_value = text

	if self._anchor then
		local size = gui.get_size(self.root)
		local pivot_offset = helper.get_pivot_offset(gui.get_pivot(self.root))
		gui.set_position(self.root, vmath.vector3(
			self._anchor.x + size.x * pivot_offset.x,
			self._anchor.y + size.y * pivot_offset.y,
			self._anchor.z
		))
	end

	self._settings.adjust_scale = 1
	local root_size = gui.get_size(self.root)
	self._settings.width = root_size.x
	self._settings.height = root_size.y
	self._settings.split_to_characters = self._split_to_characters

	local words, settings, line_metrics = rich_text.create(text, self._settings, self.style)
	line_metrics = rich_text.adjust_to_area(words, settings, line_metrics, self.style)

	self._words = words
	self._line_metrics = line_metrics

	return words, line_metrics
end

---获取富文本的当前文本
---@return string text 富文本的当前文本
function M:get_text()
	return self._last_value
end

---设置枢轴并保持内容位置（锚点）。在此之后，调整根节点大小将保持锚点固定。
---@param pivot number GUI枢轴常量
---@return druid.rich_text self
function M:set_pivot(pivot)
	local pos = gui.get_position(self.root)
	local size = gui.get_size(self.root)
	local pivot_offset = helper.get_pivot_offset(gui.get_pivot(self.root))
	self._anchor = vmath.vector3(
		pos.x - size.x * pivot_offset.x,
		pos.y - size.y * pivot_offset.y,
		pos.z
	)
	gui.set_pivot(self.root, pivot)
	pivot_offset = helper.get_pivot_offset(pivot)
	gui.set_position(self.root, vmath.vector3(
		self._anchor.x + size.x * pivot_offset.x,
		self._anchor.y + size.y * pivot_offset.y,
		pos.z
	))
	self:set_text(self._last_value)
	return self
end

---@private
---移除组件时的处理
	gui.set_scale(self.root, self._default_scale)
	gui.set_size(self.root, self._default_size)
	self:clear()
end

---清除所有创建的单词。
function M:clear()
	if self._words then
		rich_text.remove(self._words)
		self._words = nil
	end
	self._last_value = nil
end

---获取所有具有指定标签的单词。
---@param tag string 要获取单词的标签
---@return druid.rich_text.word[] words 具有指定标签的单词
function M:tagged(tag)
	if not self._words then
		return {}
	end

	return rich_text.tagged(self._words, tag)
end

---设置富文本是否应分割为字符而非单词
---@param value boolean
---@return druid.rich_text self
function M:set_split_to_characters(value)
	self._split_to_characters = value
	return self
end

---获取所有当前创建的单词，每个单词是一个包含单词信息的表格
---@return druid.rich_text.word[]
function M:get_words()
	return self._words
end

---获取当前行度量
---@return druid.rich_text.lines_metrics lines_metrics 富文本的行度量
function M:get_line_metric()
	return self._line_metrics
end

---@private
---@return table settings 富文本的设置，它们基于GUI场景中的根节点创建
function M:_create_settings()
	local root_size = gui.get_size(self.root)
	local scale = gui.get_scale(self.root)

	self._default_size = root_size
	self._default_scale = scale

	root_size.x = root_size.x * scale.x
	root_size.y = root_size.y * scale.y
	gui.set_size(self.root, root_size)
	gui.set_scale(self.root, VECTOR3_ONE)

	return {
		-- 常规设置
		-- 调整比例以使文本适合根节点区域
		adjust_scale = 1,
		parent = self.root,
		scale = scale,
		width = root_size.x,
		height = root_size.y,
		combine_words = false, -- disabled now
		text_prefab = self.text_prefab,
		pivot = gui.get_pivot(self.root),

		-- 文本设置
		shadow = gui.get_shadow(self.root),
		outline = gui.get_outline(self.root),
		text_leading = gui.get_leading(self.root),
		is_multiline = gui.get_line_break(self.root),
		split_to_characters = false,

		-- 图像设置
		image_pixel_grid_snap = false, -- disabled now
	}
end

---设置富文本的宽度，不影响当前生成单词的大小
---@param width number
---@return druid.rich_text self
function M:set_width(width)
	gui.set(self.root, "size.x", width)
	self._settings.width = width
	return self
end

---设置富文本的高度，不影响当前生成单词的大小
---@param height number
---@return druid.rich_text self
function M:set_height(height)
	gui.set(self.root, "size.y", height)
	self._settings.height = height
	return self
end

return M
