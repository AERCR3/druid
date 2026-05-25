local config = require("druid.editor_scripts.defold_parser.system.config")

--- Defold解析器模块，用于解析Defold文本格式
local M = {}

--- 键值对正则表达式示例: "name: value"
M.REGEX_KEY_COLUM_VALUE = "^%s*([%w_]+):%s*(.+)$"
--- 开始表格正则表达式示例: "name {"
M.REGEX_START_TABLE = "^%s*([%w_]*)%s*{%s*$"
--- 结束表格正则表达式示例: "}"
M.REGEX_END_TABLE = "^%s*}%s*$"


---取消转义文本字段
---此函数处理文本字段中的转义字符，将转义字符转换为正常字符
---用于处理Defold配置文件中的多行文本和特殊字符
---@param value string 包含转义字符的文本值
---@return string 处理后的字符串，转义字符被替换为正常字符
function M.unescape_text_field(value)
	--- 按行分割文本，逐行处理转义字符
	local lines = {}
	--- 使用正则表达式按行分割文本，支持Windows和Unix换行符
	for line in value:gmatch("[^\r\n]+") do
		--- 取消引号转义：\" -> "
		line = line:gsub('\"', '"')
		--- 移除换行符转义：\n -> 空字符串
		line = line:gsub("\\n", "")
		--- 取消反斜杠转义：\\ -> \
		line = line:gsub("\\", "")
		--- 将处理后的行添加到行列表中
		table.insert(lines, line)
	end

	--- 重新组合所有行为一个字符串
	--- 使用换行符连接各行，恢复原始的换行结构
	value = table.concat(lines, "\n")
	return value
end

---判断是否为多行值
---此函数检查字符串值是否包含换行符转义序列，用于判断是否为多行文本
---多行值在Defold配置文件中表示跨越多行的文本内容
---@param value string 要检查的值
---@return boolean 如果是多行值则返回true，否则返回false
function M.is_multiline_value(value)
	--- 检查是否包含换行符转义序列 \n"
	--- 这个序列出现在多行文本的最后一行之前
	--- 如果找到，说明这是多行文本值
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

---创建新的内部结构
---此函数在父对象中创建一个新的嵌套结构，并将其添加到解析栈中
---用于处理Defold配置文件中的嵌套对象结构
---@param parent_object table 父对象，新结构将被添加到此对象中
---@param name string 新结构的名称，作为父对象的键
---@param stack table 对象栈，用于跟踪嵌套结构层次
function M.new_inner_struct(parent_object, name, stack)
	--- 创建新的空对象
	local new_object = {}

	--- 将新对象添加到父对象中
	--- 使用apply_value方法处理值的应用逻辑
	M.apply_value(parent_object, name, new_object)

	--- 检查是否应该总是以数组形式处理
	--- config.ALWAYS_LIST中指定的对象名始终被当作数组处理
	local is_object_always_list = config.ALWAYS_LIST[name]
	--- 如果对象总是列表但当前不是数组，则转换为数组
	if is_object_always_list and not M.is_array(parent_object[name]) then
		--- 将现有值包装成数组，保持数据不丢失
		parent_object[name] = { parent_object[name] }
	end

	--- 将新对象压入栈中
	--- 栈用于跟踪当前的解析上下文，处理嵌套结构
	table.insert(stack, new_object)
end

---将值应用到对象
---此函数将指定的值添加到目标对象中
---如果该键已经存在值，则自动将现有值和新值都转换为数组
---这是处理Defold配置文件中重复键的重要机制
---@param object table 目标对象，值将被添加到此对象中
---@param name string 属性名称
---@param value any 要应用的值
---@return table 更新后的对象
function M.apply_value(object, name, value)
	--- 检查是否应该总是以数组形式处理
	--- config.ALWAYS_LIST中指定的对象名始终被当作数组处理
	local is_object_always_list = config.ALWAYS_LIST[name]

	--- 如果对象中还没有这个键
	if object[name] == nil then
		--- 直接设置值
		object[name] = value
		--- 如果应该总是列表形式，则转换为数组
		if is_object_always_list then
			object[name] = { object[name] }
		end
		--- 返回更新后的对象
		return object
	end

	--- 如果键已存在值，且当前不是数组形式，则转换为数组
	--- 这是处理重复键的关键逻辑
	if not M.is_array(object[name]) then
		--- 将现有值包装成数组，保持数据不丢失
		object[name] = { object[name] }
	end

	--- 将新值添加到数组中
	--- 这样处理重复键时，所有值都会被保留
	table.insert(object[name], value)

	--- 返回更新后的对象
	return object
end
end

---应用多行值
---此函数将多行文本值添加到目标对象中
---如果目标键已存在值，则用换行符连接新旧值
---用于处理Defold配置文件中的多行文本属性
---@param object table 目标对象
---@param name string 属性名称
---@param value string 要添加的多行值
---@return table 更新后的对象
function M.apply_multiline_value(object, name, value)
	--- 如果目标对象中还没有这个键
	if object[name] == nil then
		--- 直接设置值
		object[name] = value
	else
		--- 如果键已存在值，则用换行符连接新旧值
		--- 这样可以保持多行文本的完整性
		object[name] = object[name] .. "\n" .. value
	end

	--- 返回更新后的对象
	return object
end

---检查是否为数组
---这是一个简化的数组检查函数
---通过检查表是否有第一个元素来判断是否为非空数组
---@param t table 要检查的表
---@return boolean 如果是非空数组则返回true，否则返回false
function M.is_array(t)
	--- 检查类型是否为表且第一个元素存在
	--- 这种方法可以快速判断是否为非空数组
	--- 注意：这种方法不能完全验证数组格式（如索引是否连续）
	return type(t) == "table" and t[1] ~= nil
end

return M
