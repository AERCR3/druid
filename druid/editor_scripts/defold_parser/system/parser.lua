local config = require("druid.editor_scripts.defold_parser.system.config")

--- Defold解析器模块，用于解析Defold文本格式
local M = {}

--- 键值对正则表达式示例: "name: value"
M.REGEX_KEY_COLUM_VALUE = "^%s*([%w_]+):%s*(.+)$"
--- 开始表格正则表达式示例: "name {"
M.REGEX_START_TABLE = "^%s*([%w_]*)%s*{%s*$"
--- 结束表格正则表达式示例: "}"
M.REGEX_END_TABLE = "^%s*}%s*$"


--- 取消转义文本字段
--- 此函数处理文本字段中的转义字符
---@param value string 要处理的值
---@return string 处理后的字符串
function M.unescape_text_field(value)
	-- Splitting the value by new lines and processing each line
	local lines = {}
	for line in value:gmatch("[^\r\n]+") do
		line = line:gsub('\\"', '"') -- Unescaping quotes
		line = line:gsub("\\n", "") -- Removing newline escapes
		line = line:gsub("\\", "") -- Unescaping backslashes
		table.insert(lines, line)
	end

	-- Reconstructing the value
	value = table.concat(lines, "\n")
	return value
end

--- 判断是否为多行值
--- 此函数检查值是否包含多行内容
---@param value string 要检查的值
---@return boolean 如果是多行值则返回true
function M.is_multiline_value(value)
	return value:find("\\n\"") ~= nil
end

--- 解码值
--- 此函数根据属性名称和值的类型进行相应的解码处理
---@param value any 要解码的值
---@param property_name string|nil 属性名称
---@return any 解码后的值
function M.decode_value(value, property_name)
	if value:match('^".*"$') then
		-- Removing the quotes from the string
		value = value:sub(2, -2)

		-- Check if value is escaped
		-- If ends with \n
		if value:sub(-2) == "\\n" then
			value = value:gsub('\\"', '"') -- Unescaping quotes
			value = value:gsub("\\n", "")
			value = value:gsub("\\", "")
		end
	elseif value:match('^%-?[0-9.E%-]+$') then
		-- Converting to number
		value = tonumber(value)
	end

	-- Specific handling for the "text" property
	if property_name == "text" then
		value = tostring(value)
	else
		if value == "true" then
			value = true
		elseif value == "false" then
			value = false
		end
	end

	if property_name == "text" and M.is_multiline_value(value) and type(value) == "string" then
		value = M.unescape_text_field(value)
	end

	return value
end

--- 创建新的内部结构
--- 此函数在父对象中创建一个新的嵌套结构并将其添加到栈中
---@param parent_object table 父对象
---@param name string 新结构的名称
---@param stack table 对象栈
function M.new_inner_struct(parent_object, name, stack)
	local new_object = {}
	M.apply_value(parent_object, name, new_object)

	local is_object_always_list = config.ALWAYS_LIST[name]
	if is_object_always_list and not M.is_array(parent_object[name]) then
		parent_object[name] = { parent_object[name] }
	end

	table.insert(stack, new_object)
end

--- 将值应用到对象，如果值已存在，则将其转换为数组
--- 此函数将指定的值添加到对象中，如果该键已有值，则将其转换为数组
---@param object table 目标对象
---@param name string 属性名称
---@param value any 要应用的值
---@return table 更新后的对象
function M.apply_value(object, name, value)
	local is_object_always_list = config.ALWAYS_LIST[name]
	if object[name] == nil then
		object[name] = value
		if is_object_always_list then
			object[name] = { object[name] }
		end
		return object
	end

	-- Convert to array if not already
	if not M.is_array(object[name]) then
		object[name] = { object[name] }
	end

	table.insert(object[name], value)
	return object
end

---@param object table
---@param value string
---@return table @object
function M.apply_multiline_value(object, name, value)
	if object[name] == nil then
		object[name] = value
	else
		object[name] = object[name] .. "\n" .. value
	end

	return object
end

--- Check if table is array
---@param t table
---@return boolean
function M.is_array(t)
	return type(t) == "table" and t[1] ~= nil
end

return M
