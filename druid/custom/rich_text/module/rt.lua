---@diagnostic disable: inject-field
--- 富文本模块主文件
--- 源码: https://github.com/britzl/defold-richtext 版本 5.19.0
--- 作者: Britzl
--- 修改者: Insality

local helper = require("druid.helper")
local parser = require("druid.custom.rich_text.module.rt_parse")
local utf8_lua = require("druid.system.utf8")
local utf8 = utf8 or utf8_lua

local VECTOR_ZERO = vmath.vector3(0)
local COLOR_WHITE = vmath.vector4(1)

local M = {}

--- 修剪字符串开头的空格
--- 此函数移除字符串开头的所有空白字符
---@param text string 要修剪的文本
---@return string 修剪后的文本
local function ltrim(text)
	return text:match('^%s*(.*)')
end


--- 比较两个单词，检查它们是否具有相同的大小、颜色、字体和标签
--- 此函数比较两个单词对象的各个属性是否相等
---@param one table 第一个单词对象
---@param two table 第二个单词对象
---@return boolean 如果两个单词属性相同则返回true
local function compare_words(one, two)
	if one == nil
			or two == nil
			or one.size ~= two.size
			or one.color ~= two.color
			or one.shadow ~= two.shadow
			or one.outline ~= two.outline
			or one.font ~= two.font then
		return false
	end
	local one_tags, two_tags = one.tags, two.tags
	if one_tags == two_tags then
		return true
	end
	if one_tags == nil or two_tags == nil then
		return false
	end
	for k, v in pairs(one_tags) do
		if two_tags[k] ~= v then
			return false
		end
	end
	for k, v in pairs(two_tags) do
		if one_tags[k] ~= v then
			return false
		end
	end
	return true
end


--- 获取文本长度，忽略任何标签，除了图像标签被视为长度为1
--- 此函数计算富文本的实际字符长度，排除格式化标签的影响
---@param text string|table<string, any> 包含文本的字符串或单词列表（来自richtext.create）
---@return number 文本长度
function M.length(text)
	assert(text)
	if type(text) == "string" then
		return parser.length(text)
	else
		local count = 0
		for i = 1, #text do
			local word = text[i]
			local is_text_node = not word.image
			count = count + (is_text_node and utf8.len(word.text) or 1)
		end
		return count
	end
end

--- 获取文本度量信息
--- 此函数计算文本的尺寸、高度等度量信息
---@param word druid.rich_text.word 当前单词对象
---@param previous_word druid.rich_text.word|nil 上一个单词对象
---@param settings druid.rich_text.settings 富文本设置
---@return druid.rich_text.metrics 文本度量信息
local function get_text_metrics(word, previous_word, settings)
	local text = word.text
	local font_resource = gui.get_font_resource(word.font)

	---@type druid.rich_text.metrics
	local metrics
	local word_scale_x = word.relative_scale * settings.scale.x * settings.adjust_scale
	local word_scale_y = word.relative_scale * settings.scale.y * settings.adjust_scale

	if utf8.len(text) == 0 then
		metrics = resource.get_text_metrics(font_resource, "|")
		metrics.width = 0
		metrics.height = metrics.height * word_scale_y
	else
		metrics = resource.get_text_metrics(font_resource, text)
		metrics.width = metrics.width * word_scale_x
		metrics.height = metrics.height * word_scale_y

		if previous_word and not previous_word.image then
			local previous_word_metrics = resource.get_text_metrics(font_resource, previous_word.text)
			local union_metrics = resource.get_text_metrics(font_resource, previous_word.text .. text)

			local without_previous_width = metrics.width
			metrics.width = (union_metrics.width - previous_word_metrics.width) * word_scale_x
			-- Since the several characters can be ajusted to fit the space between the previous word and this word
			-- For example: chars: [.,?!]
			metrics.offset_x = metrics.width - without_previous_width
		end
	end

	metrics.offset_x = metrics.offset_x or 0
	metrics.offset_y = metrics.offset_y or 0

	return metrics
end


---@param word druid.rich_text.word
---@param settings druid.rich_text.settings
---@return druid.rich_text.metrics
local function get_image_metrics(word, settings)
	local node = word.node
	gui.set_texture(node, word.image.texture)
	gui.play_flipbook(node, word.image.anim)
	local node_size = gui.get_size(node)
	local aspect = node_size.x / node_size.y
	node_size.x = word.image.width or node_size.x
	node_size.y = word.image.height or (node_size.x / aspect)

	return {
		width = node_size.x * word.relative_scale * settings.scale.x * settings.adjust_scale,
		height = node_size.y * word.relative_scale * settings.scale.y * settings.adjust_scale,
		node_size = node_size,
	}
end


---@param word druid.rich_text.word
---@param settings druid.rich_text.settings
---@param previous_word druid.rich_text.word|nil
---@return druid.rich_text.metrics
local function measure_node(word, settings, previous_word)
	do -- Clone node if required
		local node
		if word.image then
			node = word.node or gui.new_box_node(vmath.vector3(0), vmath.vector3(word.image.width, word.image.height, 0))
		else
			node = word.node or gui.clone(settings.text_prefab)
		end
		word.node = node
	end

	if word.image then
		return get_image_metrics(word, settings)
	else
		return get_text_metrics(word, previous_word, settings)
	end
end


--- 从文本创建富文本GUI节点
--- 此函数解析富文本标记并创建相应的GUI节点
---@param text string 用于创建富文本节点的文本
---@param settings table 可选设置表（详情请参考文档）
---@param style druid.rich_text.style 富文本样式
---@return druid.rich_text.word[] 单词数组
---@return druid.rich_text.settings 设置表
---@return druid.rich_text.lines_metrics 行度量信息
function M.create(text, settings, style)
	assert(text, "You must provide a text")

	-- default settings for a word
	-- will be assigned to each word unless tags override the values
	local word_params = {
		node = nil, -- Autofill on node creation
		relative_scale = 1,
		color = nil,
		position = nil, -- Autofill later
		scale = nil,  -- Autofill later
		size = nil,   -- Autofill later
		pivot = nil,  -- Autofill later
		offset = nil, -- Autofill later
		metrics = {},
		-- text params
		source_text = nil,
		text = nil, -- Autofill later in parse.lua
		text_color = gui.get_color(settings.text_prefab),
		shadow = settings.shadow,
		outline = settings.outline,
		font = gui.get_font(settings.text_prefab),
		split_to_characters = settings.split_to_characters,
		-- Image params
		---@type druid.rich_text.word.image
		image = nil,
		-- Tags
		br = nil,
		nobr = nil,
	}

	local parsed_words = parser.parse(text, word_params, style)
	local lines = M._split_on_lines(parsed_words, settings)
	local lines_metrics = M._position_lines(lines, settings)
	M._update_nodes(lines, settings)

	local words = {}
	for index = 1, #lines do
		helper.add_array(words, lines[index])
	end

	return words, settings, lines_metrics
end

---@param word druid.rich_text.word
---@param metrics druid.rich_text.metrics
---@param settings druid.rich_text.settings
function M._fill_properties(word, metrics, settings)
	word.metrics = metrics

	word.position = word.position or vmath.vector3(0)
	word.position.x = 0
	word.position.y = 0
	word.position.z = 0

	if word.image then
		word.pivot = gui.PIVOT_CENTER
		word.size = metrics.node_size
		if word.image.width then
			word.size.y = word.image.height or (word.size.y * word.image.width / word.size.x)
			word.size.x = word.image.width
		end
		local image_scale = word.relative_scale * settings.adjust_scale
		word.scale = word.scale or vmath.vector3(image_scale)
		word.scale.x = image_scale
		word.scale.y = image_scale
		word.scale.z = image_scale

		word.offset = word.offset or vmath.vector3(0)
		word.offset.x = 0
		word.offset.y = 0
		word.offset.z = 0
	else
		word.pivot = gui.PIVOT_SW
		local text_scale = word.relative_scale * settings.adjust_scale

		word.scale = word.scale or vmath.vector3(settings.scale * text_scale)
		word.scale.x = settings.scale.x * text_scale
		word.scale.y = settings.scale.y * text_scale
		word.scale.z = settings.scale.z * text_scale

		word.size = word.size or vmath.vector3(metrics.width, metrics.height, 0)
		word.size.x = metrics.width
		word.size.y = metrics.height
		word.size.z = 0

		word.offset = word.offset or vmath.vector3(metrics.offset_x, metrics.offset_y, 0)
		word.offset.x = metrics.offset_x
		word.offset.y = metrics.offset_y
		word.offset.z = 0
	end
end

---@param words druid.rich_text.word[]
---@param settings druid.rich_text.settings
---@return druid.rich_text.word[][]
function M._split_on_lines(words, settings)
	local i = 1
	local lines = {}
	local current_line = {}
	local word_count = #words
	local current_line_width = 0
	local current_line_height = 0

	repeat
		local word = words[i]
		if word == nil then
			break
		end

		-- Reset texts to start measure again
		word.text = word.source_text

		-- get the previous word, so we can combine
		local previous_word = current_line[#current_line]
		if settings.combine_words then
			if not compare_words(previous_word, word) then
				previous_word = nil
			end
		end

		local word_metrics = measure_node(word, settings)

		local next_words_width = word_metrics.width
		-- Collect width of nobr words from current to next words with nobr
		if word.nobr then
			for index = i + 1, word_count do
				if words[index].nobr then
					local next_word_measure = measure_node(words[index], settings, words[index - 1])
					next_words_width = next_words_width + next_word_measure.width
				else
					break
				end
			end
		end
		local overflow = (current_line_width + next_words_width) > settings.width
		local is_new_line = (overflow or word.br) and settings.is_multiline and not word.nobr

		-- We recalculate metrics with previous_word if it follow for word on current line
		if not is_new_line and previous_word then
			word_metrics = measure_node(word, settings, previous_word)
		end

		-- Trim first word of the line
		if is_new_line or not previous_word then
			word.text = ltrim(word.text)
			word_metrics = measure_node(word, settings, nil)
		end
		M._fill_properties(word, word_metrics, settings)

		-- check if the line overflows due to this word
		if not is_new_line then
			-- the word fits on the line, add it and update text metrics
			current_line_width = current_line_width + word.metrics.width
			current_line_height = math.max(current_line_height, word.metrics.height)
			current_line[#current_line + 1] = word
		else
			-- overflow, position the words that fit on the line
			lines[#lines + 1] = current_line

			word.text = ltrim(word.text)
			current_line = { word }
			current_line_height = word.metrics.height
			current_line_width = word.metrics.width
		end

		i = i + 1
	until i > word_count

	if #current_line > 0 then
		lines[#lines + 1] = current_line
	end

	return lines
end

---@param lines druid.rich_text.word[][]
---@param settings druid.rich_text.settings
---@return druid.rich_text.lines_metrics
function M._position_lines(lines, settings)
	local lines_metrics = M._get_lines_metrics(lines, settings)
	-- current x-y is left top point of text spawn

	local parent_size = gui.get_size(settings.parent)
	local pivot = helper.get_pivot_offset(gui.get_pivot(settings.parent))
	local offset_y = (parent_size.y - lines_metrics.text_height) * (pivot.y - 0.5) - (parent_size.y * (pivot.y - 0.5))

	local current_y = offset_y
	for line_index = 1, #lines do
		local line = lines[line_index]
		local line_metrics = lines_metrics.lines[line_index]
		local current_x = (parent_size.x - line_metrics.width) * (pivot.x + 0.5) - (parent_size.x * (pivot.x + 0.5))
		local max_height = 0
		for word_index = 1, #line do
			local word = line[word_index]
			local pivot_offset = helper.get_pivot_offset(word.pivot)
			local word_width = word.metrics.width
			word.position.x = current_x + word_width * (pivot_offset.x + 0.5) + word.offset.x
			word.position.y = current_y + word.metrics.height * (pivot_offset.y - 0.5) + word.offset.y

			-- Align item on text line depends on anchor
			word.position.y = word.position.y - (word.metrics.height - line_metrics.height) * (pivot_offset.y - 0.5)

			current_x = current_x + word_width

			-- TODO: check if we need to calculate images
			if not word.image then
				max_height = math.max(max_height, word.metrics.height)
			end

			if settings.image_pixel_grid_snap and word.image then
				word.position.x = helper.round(word.position.x)
				word.position.y = helper.round(word.position.y)
			end
		end

		current_y = current_y - line_metrics.height
	end

	return lines_metrics
end

---@param lines druid.rich_text.word[][]
---@param settings druid.rich_text.settings
---@return druid.rich_text.lines_metrics
function M._get_lines_metrics(lines, settings)
	local metrics = {}
	local text_width = 0
	local text_height = 0
	for line_index = 1, #lines do
		local line = lines[line_index]
		local width = 0
		local height = 0
		for word_index = 1, #line do
			local word = line[word_index]
			local word_width = word.metrics.width
			width = width + word_width
			-- TODO: Here too
			if not word.image then
				height = math.max(height, word.metrics.height)
			end
		end

		if line_index > 1 then
			height = height * settings.text_leading
		end

		text_width = math.max(text_width, width)
		text_height = text_height + height

		metrics[#metrics + 1] = {
			width = width,
			height = height,
		}
	end

	---@type druid.rich_text.lines_metrics
	local lines_metrics = {
		text_width = text_width,
		text_height = text_height,
		lines = metrics,
	}

	return lines_metrics
end

---@param lines druid.rich_text.word[][]
---@param settings druid.rich_text.settings
function M._update_nodes(lines, settings)
	for line_index = 1, #lines do
		local line = lines[line_index]
		for word_index = 1, #line do
			local word = line[word_index]
			local node
			if word.image then
				node = word.node or gui.new_box_node(VECTOR_ZERO, word.size)
				gui.set_size_mode(node, gui.SIZE_MODE_MANUAL)
				gui.set_texture(node, word.image.texture)
				gui.play_flipbook(node, hash(word.image.anim))
				gui.set_color(node, word.color or COLOR_WHITE)
				gui.set_inherit_alpha(node, true)
			else
				node = word.node or gui.clone(settings.text_prefab)
				gui.set_outline(node, word.outline)
				gui.set_shadow(node, word.shadow)
				gui.set_text(node, word.text)
				gui.set_color(node, word.color or word.text_color)
				gui.set_font(node, word.font or settings.font)
			end
			word.node = node
			gui.set_enabled(node, true)
			gui.set_parent(node, settings.parent)
			gui.set_pivot(node, word.pivot)
			gui.set_size(node, word.size)
			gui.set_scale(node, word.scale)
			gui.set_position(node, word.position)
		end
	end
end

--- 设置文本缩放
--- 此函数设置富文本的整体缩放比例
---@param words druid.rich_text.word[] 单词数组
---@param settings druid.rich_text.settings 设置表
---@param scale number 缩放比例
---@return druid.rich_text.lines_metrics 行度量信息
function M.set_text_scale(words, settings, scale)
	settings.adjust_scale = scale

	local lines = M._split_on_lines(words, settings)
	local line_metrics = M._position_lines(lines, settings)
	M._update_nodes(lines, settings)

	return line_metrics
end

--- 调整到区域内
--- 此函数将富文本调整以适应指定的区域大小
---@param words druid.rich_text.word[] 单词数组
---@param settings druid.rich_text.settings 设置表
---@param lines_metrics druid.rich_text.lines_metrics 行度量信息
---@param style druid.rich_text.style 样式设置
function M.adjust_to_area(words, settings, lines_metrics, style)
	local last_line_metrics = lines_metrics

	if not settings.is_multiline then
		if lines_metrics.text_width > settings.width then
			last_line_metrics = M.set_text_scale(words, settings, settings.width / lines_metrics.text_width)
		end
	else
		-- Multiline adjusting is very tricky stuff...
		-- It's doing a lot of calculations, beware!
		if lines_metrics.text_width > settings.width or lines_metrics.text_height > settings.height then
			local scale_koef = math.sqrt(settings.height / lines_metrics.text_height)
			if lines_metrics.text_width * scale_koef > settings.width then
				scale_koef = math.sqrt(settings.width / lines_metrics.text_width)
			end
			local adjust_scale = math.min(scale_koef, settings.scale.x)

			local lines = M.apply_scale_without_update(words, settings, adjust_scale)
			local is_fit = M.is_fit_info_area(lines, settings)
			local step = is_fit and style.ADJUST_SCALE_DELTA or -style.ADJUST_SCALE_DELTA

			for i = 1, style.ADJUST_STEPS do
				-- Grow down to check if we fit
				if step < 0 and is_fit then
					last_line_metrics = M.set_text_scale(words, settings, adjust_scale)
					break
				end
				-- Grow up to check if we still fit
				if step > 0 and not is_fit then
					last_line_metrics = M.set_text_scale(words, settings, adjust_scale - step)
					break
				end

				adjust_scale = adjust_scale + step
				lines = M.apply_scale_without_update(words, settings, adjust_scale)
				is_fit = M.is_fit_info_area(lines, settings)

				if i == style.ADJUST_STEPS then
					last_line_metrics = M.set_text_scale(words, settings, adjust_scale)
				end
			end
		end
	end

	return last_line_metrics
end

--- 应用缩放但不更新节点
--- 此函数应用缩放变换但不更新实际的GUI节点
---@return druid.rich_text.word[][] lines 按行分割的单词数组
function M.apply_scale_without_update(words, settings, scale)
	settings.adjust_scale = scale
	return M._split_on_lines(words, settings)
end

---@param lines druid.rich_text.word[][]
---@param settings druid.rich_text.settings
function M.is_fit_info_area(lines, settings)
	local lines_metrics = M._get_lines_metrics(lines, settings)
	local area_size = gui.get_size(settings.parent)
	return lines_metrics.text_width <= area_size.x and lines_metrics.text_height <= area_size.y
end

--- 获取所有具有特定标签的单词
--- 此函数搜索并返回所有具有指定标签的单词
---@param words druid.rich_text.word[] 要搜索的单词数组（来自richtext.create的结果）
---@param tag string|nil 要搜索的标签。Nil表示搜索没有标签的单词
---@return druid.rich_text.word[] 匹配标签的单词数组
function M.tagged(words, tag)
	local tagged = {}
	for i = 1, #words do
		local word = words[i]
		if not tag and not word.tags then
			tagged[#tagged + 1] = word
		elseif word.tags and word.tags[tag] then
			tagged[#tagged + 1] = word
		end
	end
	return tagged
end

---移除富文本创建的GUI节点
---@param words druid.rich_text.word[] 富文本单词数组
function M.remove(words)
	assert(words)

	for i = 1, #words do
		gui.delete_node(words[i].node)
	end
end

return M
