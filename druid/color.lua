local logger = require("druid.system.druid_logger")

---@alias color vector4|vector3|string

---颜色调色板和用于处理颜色的实用函数。
---支持调色板管理、十六进制转换、RGB/HSB转换和颜色插值。
---该模块提供了一整套颜色处理功能，方便开发者管理UI中的颜色
---@class druid.color
local M = {}

local PALETTE_DATA = {}
local COLOR_WHITE = vmath.vector4(1, 1, 1, 1)
local COLOR_X = hash("color.x")
local COLOR_Y = hash("color.y")
local COLOR_Z = hash("color.z")


---从调色板按ID获取颜色、十六进制字符串，或直接返回向量。
---如果在调色板中找不到color_id且不是十六进制字符串，则返回白色。
---此函数提供了统一的颜色获取接口，支持多种颜色表示方式
---@param color_id string|vector4|vector3 来自调色板的颜色ID、十六进制颜色字符串或向量
---@return vector4
function M.get_color(color_id)
	if type(color_id) ~= "string" then
		---@cast color_id vector4
		return color_id
	end

	if PALETTE_DATA[color_id] then
		return PALETTE_DATA[color_id]
	end

	-- Check is it hex: starts with "#" or contains only 3 or 6 hex symbols
	if type(color_id) == "string" then
		if string.sub(color_id, 1, 1) == "#" or string.match(color_id, "^[0-9a-fA-F]+$") then
			return M.hex2vector4(color_id)
		end
	end

	logger.warn("Color not found in palette", color_id)

	return COLOR_WHITE
end

---向调色板添加颜色。颜色可以是十六进制字符串或vector4值。
---此函数用于扩展默认调色板，便于在项目中复用常用颜色
---@param palette_data table<string, vector4|string> 以颜色ID为键的表格
function M.add_palette(palette_data)
	for color_id, color in pairs(palette_data) do
		if type(color) == "string" then
			PALETTE_DATA[color_id] = M.hex2vector4(color)
		else
			PALETTE_DATA[color_id] = color
		end
	end
end

---获取所有调色板颜色。
---此函数返回当前已定义的所有颜色，可用于调试或动态选择颜色
---@return table<string, vector4>
function M.get_palette()
	return PALETTE_DATA
end

---设置GUI节点颜色。不改变透明度。
---此函数专门用于设置GUI节点的颜色属性，但不影响透明度通道
---@param gui_node node GUI节点
---@param color vector4|vector3|string 颜色值
function M.set_color(gui_node, color)
	if type(color) == "string" then
		color = M.get_color(color)
	end

	gui.set(gui_node, COLOR_X, color.x)
	gui.set(gui_node, COLOR_Y, color.y)
	gui.set(gui_node, COLOR_Z, color.z)
end

---在两种颜色之间使用HSB空间进行插值（比RGB产生更好的视觉效果）。
---HSB色彩空间的插值能产生更自然的颜色过渡效果
---@param t number 插值系数（0 = color1, 1 = color2）
---@param color1 vector4 第一种颜色
---@param color2 vector4 第二种颜色
---@return vector4 插值后的颜色
function M.lerp(t, color1, color2)
	local h1, s1, v1 = M.rgb2hsb(color1.x, color1.y, color1.z)
	local h2, s2, v2 = M.rgb2hsb(color2.x, color2.y, color2.z)

	local dh = h2 - h1
	if math.abs(dh) > 0.5 then
		if dh > 0 then
			dh = dh - 1
		else
			dh = dh + 1
		end
	end
	local h = (h1 + dh * t) % 1
	local s = s1 + (s2 - s1) * t
	local v = v1 + (v2 - v1) * t

	local a1 = color1.w or 1
	local a2 = color2.w or 1
	local a = a1 + (a2 - a1) * t

	local r, g, b = M.hsb2rgb(h, s, v)

	return vmath.vector4(r, g, b, a)
end

---将十六进制字符串转换为RGB值（0-1范围）。支持#RGB和#RRGGBB格式。
---此函数处理常见的十六进制颜色格式转换，便于设计师和开发者协作
---@param hex string 十六进制颜色字符串
---@return number, number, number R、G、B分量值
function M.hex2rgb(hex)
	if not hex or #hex < 3 then
		return 0, 0, 0
	end

	hex = hex:gsub("^#", "")
	if #hex == 3 then
		hex = hex:gsub("(.)", "%1%1")
	end
	return tonumber("0x" .. hex:sub(1, 2)) / 255,
			tonumber("0x" .. hex:sub(3, 4)) / 255,
			tonumber("0x" .. hex:sub(5, 6)) / 255
end

---将十六进制字符串转换为vector4。
---此函数将标准的十六进制颜色值转换为Defold引擎使用的vector4格式
---@param hex string 十六进制颜色字符串
---@param alpha number|nil 透明度，默认为1
---@return vector4 vector4格式的颜色值
function M.hex2vector4(hex, alpha)
	local r, g, b = M.hex2rgb(hex)
	return vmath.vector4(r, g, b, alpha or 1)
end

---将RGB转换为HSB。
---HSB（色相、饱和度、亮度）色彩模型更适合人类直观理解颜色
---@param r number 红色分量
---@param g number 绿色分量
---@param b number 蓝色分量
---@param alpha number|nil 透明度
---@return number, number, number, number 色相、饱和度、亮度、透明度
function M.rgb2hsb(r, g, b, alpha)
	alpha = alpha or 1
	local min, max = math.min(r, g, b), math.max(r, g, b)
	local delta = max - min
	local h, s, v = 0, max, max

	s = max ~= 0 and delta / max or 0

	if delta ~= 0 then
		if r == max then
			h = (g - b) / delta
		elseif g == max then
			h = 2 + (b - r) / delta
		else
			h = 4 + (r - g) / delta
		end
		h = (h / 6) % 1
	end

	return h, s, v, alpha
end

---将HSB转换为RGB。
---@param h number 色相值
---@param s number 饱和度
---@param v number 亮度
---@param alpha number|nil 透明度
---@return number, number, number, number|nil 返回红、绿、蓝、透明度值
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

---将RGB转换为十六进制字符串（大写，不带#号）。
---@param red number 红色分量
---@param green number 绿色分量
---@param blue number 蓝色分量
---@return string hex_string 十六进制字符串，示例："FF0000"，不带"#"前缀
function M.rgb2hex(red, green, blue)
	local r = string.format("%x", math.floor(red * 255))
	local g = string.format("%x", math.floor(green * 255))
	local b = string.format("%x", math.floor(blue * 255))
	return string.upper((#r == 1 and "0" or "") .. r .. (#g == 1 and "0" or "") .. g .. (#b == 1 and "0" or "") .. b)
end

-- 如果在game.project中设置了druid.palette_path，则自动从配置加载调色板
local DEFAULT_PALETTE_PATH = sys.get_config_string("druid.palette_path")
if DEFAULT_PALETTE_PATH then
	local loaded_palette = sys.load_resource(DEFAULT_PALETTE_PATH)
	local data = loaded_palette and json.decode(loaded_palette)
	if data then
		M.add_palette(data)
	end
end


return M
