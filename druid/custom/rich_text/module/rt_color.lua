--- 富文本颜色解析模块
--- 源码: https://github.com/britzl/defold-richtext 版本 5.19.0
--- 作者: Britzl
--- 修改者: Insality

local M = {}
local cache = {} -- 颜色缓存表，用于提高性能

--- 解析十六进制颜色值
--- 此函数将十六进制颜色字符串（如#FF0000或#FF0000AA）转换为vector4颜色值
---@param hex string 十六进制颜色字符串，可选包含#前缀和alpha通道
---@return vector4|nil 解析后的颜色向量，如果解析失败则返回nil
function M.parse_hex(hex)
	if cache[hex] then
		return cache[hex]
	end

	local r, g, b, a = hex:match("#?(%x%x)(%x%x)(%x%x)(%x?%x?)")
	if a == "" then a = "ff" end
	if r and g and b and a then
		local color = vmath.vector4(
			tonumber(r, 16) / 255,
			tonumber(g, 16) / 255,
			tonumber(b, 16) / 255,
			tonumber(a, 16) / 255
		)

		cache[hex] = color
		return color
	end
	return nil
end

--- 解析十进制颜色值
--- 此函数将十进制颜色字符串（如"1,0,0,1"）转换为vector4颜色值
---@param dec string 十进制颜色字符串，格式为"r,g,b,a"，值范围0-1
---@return vector4|nil 解析后的颜色向量，如果解析失败则返回nil
function M.parse_decimal(dec)
	if cache[dec] then
		return cache[dec]
	end

	local r, g, b, a = dec:match("(%d*%.?%d*),(%d*%.?%d*),(%d*%.?%d*),(%d*%.?%d*)")
	if r and g and b and a then
		local color = vmath.vector4(tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0, tonumber(a) or 1)
		cache[dec] = color
		return color
	end
	return nil
end

--- 通用颜色解析函数
--- 此函数尝试解析十六进制或十进制颜色字符串
---@param c string 颜色字符串，可以是十六进制（如#FF0000）或十进制（如"1,0,0,1"）
---@return vector4|nil 解析后的颜色向量，如果解析失败则返回nil
function M.parse(c)
	return M.parse_hex(c) or M.parse_decimal(c)
end

return M
