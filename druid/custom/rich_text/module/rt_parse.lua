--- 富文本解析模块
--- 源码: https://github.com/britzl/defold-richtext 版本 5.19.0
--- 作者: Britzl
--- 修改者: Insality

local tags = require("druid.custom.rich_text.module.rt_tags")
local utf8_lua = require("druid.system.utf8")
local utf8 = utf8 or utf8_lua

local M = {}

--- 解析标签
--- 此函数解析富文本标签及其参数，并应用样式设置
---@param tag string 标签名称
---@param params string 标签参数
---@param style table 样式表
---@return table 解析后的设置
local function parse_tag(tag, params, style)
	local settings = { tags = { [tag] = params }, tag = tag }
	if not tags.apply(tag, params, settings, style) then
		settings[tag] = params
	end

	return settings
end


--- 向单词列表中添加单个单词
--- 此函数将文本添加到单词列表中，并处理HTML实体
---@param text string 要添加的文本
---@param settings table 当前设置
---@param words table 单词列表
---@return table 添加的单词对象
local function add_word(text, settings, words)
	-- 处理HTML实体
	text = text:gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&nbsp;", " ")

	local data = { text = text, source_text = text }
	for k, v in pairs(settings) do
		data[k] = v
	end

	words[#words + 1] = data
	return data
end


--- 将一行文本分割为单词
--- 此函数将一行文本按空格分割成单词，并处理首尾空白字符
---@param line string 要分割的行
---@param settings table 当前设置
---@param words table 单词列表
local function split_line(line, settings, words)
	assert(line)
	assert(settings)
	assert(words)

	local ws_start, trimmed_text, ws_end = line:match("^(%s*)(.-)(%s*)$")
	if trimmed_text == "" then
		add_word(ws_start .. ws_end, settings, words)
	else
		local wi = #words
		for word in trimmed_text:gmatch("%S+") do
			if settings.split_to_characters then
				for i = 1, #word do
					local symbol = utf8.sub(word, i, i)
					local w = add_word(symbol, settings, words)
					w.nobr = true
				end
				add_word(" ", settings, words)
			else
				add_word(word .. " ", settings, words)
			end
		end
		local first = words[wi + 1]
		first.text = ws_start .. first.text
		first.source_text = first.text
		local last = words[#words]
		last.text = utf8.sub(last.text, 1, utf8.len(last.text) - 1) .. ws_end
		last.source_text = last.text
	end
end


--- 分割文本
--- 首先按行分割文本
---@param text string 要分割的文本
---@param settings table 当前设置
---@param words table 单词列表
local function split_text(text, settings, words)
	assert(text)
	assert(settings)
	assert(words)
	-- 特殊处理带有换行符的空文本 <br/>
	if text == "" and settings.linebreak then
		add_word(text, settings, words)
		return
	end

	-- 我们不想处理 \r\n，移除所有 \r
	text = text:gsub("\r", "")

	-- Lua模式期望文本末尾有一个换行符
	local added_linebreak = false
	if text:sub(-1) ~= "\n" then
		added_linebreak = true
		text = text .. "\n"
	end

	-- 分割成行
	for line in text:gmatch("(.-)\n") do
		split_line(line, settings, words)
		-- 标记行的最后一个单词为有换行符
		local last = words[#words]
		last.linebreak = true
	end

	-- 如果上面手动添加了换行符，则移除最后一个换行符
	if added_linebreak then
		local last = words[#words]
		last.linebreak = false
	end
end


--- 将一个标签合并到另一个标签
--- 此函数将源标签的所有属性合并到目标标签中
---@param dst table 目标标签表
---@param src table 源标签表
local function merge_tags(dst, src)
	for k, v in pairs(src) do
		if k ~= "tags" then
			dst[k] = v
		end
	end
	for tag, params in pairs(src.tags or {}) do
		dst.tags[tag] = (params == "") and true or params
	end
end


---将文本解析为单个单词
---@param text string 要解析的文本
---@param default_settings table<string, any> 每个单词的默认设置
---@param style table<string, any> 样式设置
---@return table<string, any> 所有单词的列表
function M.parse(text, default_settings, style)
	assert(text)
	assert(default_settings)

	text = text:gsub("&zwsp;", "<zwsp>\226\128\139</zwsp>")

	-- 将所有\n替换为<br/>以便于分割文本
	text = text:gsub("\n", "<br/>")

	local all_words = {}
	local open_tags = {}

	while true do
		-- 合并默认设置和所有开放标签的单词设置列表
		local word_settings = { tags = {} }
		merge_tags(word_settings, default_settings)
		for _, open_tag in ipairs(open_tags) do
			merge_tags(word_settings, open_tag)
		end

		-- 查找下一个标签，以及标签前后的文本
		local before_tag, tag, after_tag = text:match("(.-)(</?%S->)(.*)")

		-- 没有更多标签，分割并添加剩余文本
		if not before_tag or not tag or not after_tag then
			if text ~= "" then
				split_text(text, word_settings, all_words)
			end
			break
		end

		-- 分割并添加遇到标签之前的文本
		if before_tag ~= "" then
			split_text(before_tag, word_settings, all_words)
		end

		-- 解析标签，分割为名称和可选参数
		local endtag, name, params, empty = tag:match("<(/?)([%w_]+)=?(%S-)(/?)>")

		local is_endtag = endtag == "/"
		local is_empty = empty == "/"
		if is_empty then
			-- 空标签，即没有内容的标签
			-- 示例 <br/> 和 <img=texture:image/>
			local empty_tag_settings = parse_tag(name, params, style)
			merge_tags(empty_tag_settings, word_settings)
			add_word("", empty_tag_settings, all_words)
		elseif not is_endtag then
			-- 开放标签 - 解析并添加它
			local tag_settings = parse_tag(name, params, style)
			open_tags[#open_tags + 1] = tag_settings
		else
			-- 结束标签 - 从开放标签列表中移除它
			local found = false
			for i = #open_tags, 1, -1 do
				if open_tags[i].tag == name then
					table.remove(open_tags, i)
					found = true
					break
				end
			end
			if not found then print(("Found end tag '%s' without matching start tag"):format(name)) end
		end

		-- 在下一次迭代中解析标签后的文本
		text = after_tag
	end

	return all_words
end

---获取文本长度，排除所有标签（图像和骨骼标签除外）
---@param text string 要获取长度的文本
---@return number 文本的长度
function M.length(text)
	return utf8.len(text:gsub("<img.-/>", " "):gsub("<.->", ""))
end

return M
