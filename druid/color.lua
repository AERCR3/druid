local logger = require("druid.system.druid_logger")

---@alias color vector4|vector3|string

---颜色处理模块
---提供完整的颜色管理功能，包括调色板管理、颜色转换和插值计算
---支持多种颜色格式：vector4、vector3、十六进制字符串，并提供便捷的颜色处理函数
---@class druid.color
local M = {}

--- 全局颜色数据
--- PALETTE_DATA: 存储调色板中的颜色映射表
--- COLOR_WHITE: 默认白色颜色常量
--- COLOR_X/Y/Z: GUI节点的颜色属性哈希值，用于设置节点的RGB通道
local PALETTE_DATA = {}
local COLOR_WHITE = vmath.vector4(1, 1, 1, 1)
local COLOR_X = hash("color.x")
local COLOR_Y = hash("color.y")
local COLOR_Z = hash("color.z")


---获取颜色值
---从调色板中根据ID获取颜色，或直接处理十六进制字符串、向量格式的颜色
---如果找不到对应的颜色ID且不是有效的十六进制字符串，则返回默认白色
---@param color_id string|vector4|vector3 颜色标识符，可以是：
---   - 调色板中的颜色ID字符串
---   - 十六进制颜色字符串（如"#FF0000"或"FF0000"）
---   - vector3或vector4格式的颜色向量
---@return vector4 RGBA格式的颜色向量（包含透明度通道）
function M.get_color(color_id)
	-- 如果输入不是字符串，则认为是向量格式的颜色，直接返回
	if type(color_id) ~= "string" then
		---@cast color_id vector4
		return color_id
	end

	-- 首先检查调色板中是否有对应的颜色ID
	if PALETTE_DATA[color_id] then
		return PALETTE_DATA[color_id]
	end

	-- 检查是否为十六进制格式的颜色字符串
	-- 支持"#"开头的6位十六进制或3位十六进制格式
	if type(color_id) == "string" then
		if string.sub(color_id, 1, 1) == "#" or string.match(color_id, "^[0-9a-fA-F]+$") then
			return M.hex2vector4(color_id)
		end
	end

	-- 如果颜色未找到，记录警告日志并返回默认白色
	logger.warn("Color not found in palette", color_id)

	return COLOR_WHITE
end

---向调色板添加颜色
---批量向项目调色板中添加新的颜色定义，便于在UI中统一管理颜色
---@param palette_data table<string, vector4|string> 颜色数据表
---   key: 颜色ID字符串（用于后续引用）
---   value: 颜色值，可以是vector4格式的颜色或十六进制字符串
function M.add_palette(palette_data)
	-- 遍历提供的颜色数据表
	for color_id, color in pairs(palette_data) do
		-- 如果颜色是字符串格式，转换为vector4格式存储
		if type(color) == "string" then
			PALETTE_DATA[color_id] = M.hex2vector4(color)
		else
			-- 如果已经是vector4格式，直接存储
			PALETTE_DATA[color_id] = color
		end
	end
end

---获取调色板中的所有颜色
---返回当前已定义的所有颜色映射表，可用于调试或动态颜色管理
---@return table<string, vector4> 包含所有颜色ID和对应颜色向量的映射表
function M.get_palette()
	return PALETTE_DATA
end

---设置GUI节点颜色
---为指定的GUI节点设置颜色，但保持其原有的透明度不变
---此函数专门用于设置RGB颜色通道，不影响alpha通道
---@param gui_node node 目标GUI节点
---@param color vector4|vector3|string 颜色值，可以是：
---   - vector4: RGBA格式的颜色向量
---   - vector3: RGB格式的颜色向量（无alpha）
---   - string: 十六进制颜色字符串或调色板颜色ID
function M.set_color(gui_node, color)
	-- 如果输入是字符串格式，先获取对应的颜色向量
	if type(color) == "string" then
		color = M.get_color(color)
	end

	-- 分别设置GUI节点的RGB三个颜色通道
	-- 使用预先计算好的哈希值提高性能
	gui.set(gui_node, COLOR_X, color.x)
	gui.set(gui_node, COLOR_Y, color.y)
	gui.set(gui_node, COLOR_Z, color.z)
end

---颜色插值函数（HSB色彩空间）
---在两种颜色之间进行插值，使用HSB（色调、饱和度、亮度）色彩空间
---相比RGB空间的线性插值，HSB插值能产生更自然、更符合视觉感知的颜色过渡效果
---@param t number 插值系数，范围[0,1]：
---   - 0: 完全使用color1颜色
---   - 1: 完全使用color2颜色
---   - 0.5: 两种颜色的中间色
---@param color1 vector4 起始颜色（RGBA格式）
---@param color2 vector4 目标颜色（RGBA格式）
---@return vector4 插值后的颜色（RGBA格式）
function M.lerp(t, color1, color2)
	local h1, s1, v1 = M.rgb2hsb(color1.x, color1.y, color1.z)
	local h2, s2, v2 = M.rgb2hsb(color2.x, color2.y, color2.z)

	-- 计算色相差值，处理色相环的循环特性
	-- 色相是环状的（0-1），所以需要处理跨越0.5的情况
	local dh = h2 - h1
	if math.abs(dh) > 0.5 then
		if dh > 0 then
			dh = dh - 1 -- 色相差超过0.5时，减1回到-0.5到0.5范围
		else
			dh = dh + 1 -- 色相差小于-0.5时，加1回到-0.5到0.5范围
		end
	end

	-- 在色相环上进行线性插值
	local h = (h1 + dh * t) % 1
	-- 饱和度和亮度进行标准线性插值
	local s = s1 + (s2 - s1) * t
	local v = v1 + (v2 - v1) * t

	-- 处理透明度通道的插值
	local a1 = color1.w or 1
	local a2 = color2.w or 1
	local a = a1 + (a2 - a1) * t

	-- 将HSB值转换回RGB格式返回
	local r, g, b = M.hsb2rgb(h, s, v)

	return vmath.vector4(r, g, b, a)
end

---十六进制颜色转RGB函数
---将十六进制格式的颜色字符串转换为RGB分量值（0-1范围）
---支持#RGB简写格式和#RRGGBB标准格式，自动处理前缀#号
---@param hex string 十六进制颜色字符串，支持：
---   - "RGB"：3位十六进制格式（如"F00"）
---   - "#RGB"：带#号的3位格式
---   - "RRGGBB"：6位十六进制格式（如"FF0000"）
---   - "#RRGGBB"：带#号的6位格式
---@return number, number, number RGB三个分量的值，范围0-1
function M.hex2rgb(hex)
	-- 输入验证：检查hex是否有效且长度足够
	if not hex or #hex < 3 then
		return 0, 0, 0 -- 无效输入返回黑色
	end

	-- 移除前导的#号，统一处理格式
	hex = hex:gsub("^#", "")
	-- 如果是3位格式（如"F00"），扩展为6位格式（如"FF0000"）
	if #hex == 3 then
		hex = hex:gsub("(.)", "%1%1")
	end
	-- 将十六进制字符串转换为数值，并除以255归一化到0-1范围
	return tonumber("0x" .. hex:sub(1, 2)) / 255,
			tonumber("0x" .. hex:sub(3, 4)) / 255,
			tonumber("0x" .. hex:sub(5, 6)) / 255
end

---十六进制颜色转vector4函数
---将十六进制颜色字符串转换为Defold引擎使用的vector4格式
---此函数提供了完整RGBA颜色格式的便捷转换
---@param hex string 十六进制颜色字符串，支持与hex2rgb相同的格式
---@param alpha number|nil 透明度值（0-1范围），默认为1（完全不透明）
---@return vector4 RGBA格式的颜色向量，格式为(r, g, b, a)
function M.hex2vector4(hex, alpha)
	-- 先将十六进制字符串转换为RGB分量，然后组合成vector4格式
	local r, g, b = M.hex2rgb(hex)
	return vmath.vector4(r, g, b, alpha or 1)
end

---RGB转HSB色彩空间函数
---将RGB（红绿蓝）颜色值转换为HSB（色相、饱和度、亮度）色彩空间
---HSB色彩空间更符合人类对颜色的直观感知，便于进行颜色调整
---@param r number 红色分量值（0-1范围）
---@param g number 绿色分量值（0-1范围）
---@param b number 蓝色分量值（0-1范围）
---@param alpha number|nil 透明度值（0-1范围），可选参数，默认为1
---@return number, number, number, number 色相[0-1]、饱和度[0-1]、亮度[0-1]、透明度值
function M.rgb2hsb(r, g, b, alpha)
	-- 设置默认透明度
	alpha = alpha or 1
	-- 找出RGB三个分量中的最大值和最小值
	local min, max = math.min(r, g, b), math.max(r, g, b)
	-- 计算RGB值的范围（差异）
	local delta = max - min
	-- 初始化色相为0，饱和度和亮度设为最大值
	local h, s, v = 0, max, max

	-- 计算饱和度：差异与最大值的比值
	-- 如果最大值为0（全黑），则饱和度为0
	s = max ~= 0 and delta / max or 0

	-- 如果有色彩差异（不是灰度），计算色相值
	if delta ~= 0 then
		if r == max then
			-- 红色是主色调：色相在0-60度范围
			h = (g - b) / delta
		elseif g == max then
			-- 绿色是主色调：色相在120-180度范围
			h = 2 + (b - r) / delta
		else
			-- 蓝色是主色调：色相在240-300度范围
			h = 4 + (r - g) / delta
		end
		-- 将色相从0-6范围转换为0-1范围，并进行归一化处理
		h = (h / 6) % 1
	end

	return h, s, v, alpha
end

---HSB转RGB色彩空间函数
---将HSB（色相、饱和度、亮度）颜色值转换为RGB（红绿蓝）格式
---这是RGB转HSB的逆变换，用于显示和计算
---@param h number 色相值（0-1范围，0=红色，0.33=绿色，0.66=蓝色）
---@param s number 饱和度（0-1范围，0=灰色，1=完全饱和）
---@param v number 亮度（0-1范围，0=黑色，1=最亮）
---@param alpha number|nil 透明度值（0-1范围），可选参数
---@return number, number, number, number|nil RGB三个分量值和透明度值
function M.hsb2rgb(h, s, v, alpha)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)

	i = i % 6

	if i == 0 then
		r, g, b = v, t, p
	elseif i == 1 then
		r, g, b = q, v, p
	elseif i == 2 then
		r, g, b = p, v, t
	elseif i == 3 then
		r, g, b = p, q, v
	elseif i == 4 then
		r, g, b = t, p, v
	elseif i == 5 then
		r, g, b = v, p, q
	end

	return r, g, b, alpha
end

---RGB转十六进制字符串函数
---将RGB颜色值转换为十六进制字符串格式（大写，不带#号）
---此函数提供了与hex2rgb相反的转换功能，便于颜色数据存储和传输
---@param red number 红色分量值（0-1范围）
---@param green number 绿色分量值（0-1范围）
---@param blue number 蓝色分量值（0-1范围）
---@return string 十六进制颜色字符串，格式为"RRGGBB"（大写，不带"#"前缀），示例："FF0000"
function M.rgb2hex(red, green, blue)
	-- 将RGB分量值（0-1）转换为十六进制值（00-FF）
	local r = string.format("%x", math.floor(red * 255))
	local g = string.format("%x", math.floor(green * 255))
	local b = string.format("%x", math.floor(blue * 255))

	-- 确保每个颜色分量都是2位十六进制，如果只有1位则在前面补0
	-- 例如：F -> 0F，FF -> FF
	-- 然后组合成完整的6位十六进制字符串并转换为大写
	return string.upper((#r == 1 and "0" or "") .. r .. (#g == 1 and "0" or "") .. g .. (#b == 1 and "0" or "") .. b)
end

--- 自动加载默认调色板配置
--- 如果在game.project文件中设置了druid.palette_path配置项，
--- 系统会自动从指定路径加载JSON格式的调色板配置
--- 这样可以在项目启动时自动加载预设的颜色主题

-- 从game.project配置中获取调色板文件路径
local DEFAULT_PALETTE_PATH = sys.get_config_string("druid.palette_path")
if DEFAULT_PALETTE_PATH then
	-- 加载调色板资源文件
	local loaded_palette = sys.load_resource(DEFAULT_PALETTE_PATH)
	-- 解析JSON格式的调色板数据
	local data = loaded_palette and json.decode(loaded_palette)
	-- 如果成功加载并解析了调色板数据，则添加到全局调色板中
	if data then
		M.add_palette(data)
	end
end


return M
