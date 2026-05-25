--- Rich Text标签处理模块
--- 源代码基于：https://github.com/britzl/defold-richtext version 5.19.0
--- 原始作者：Britzl
--- 修改者：Insality
--- 本模块处理富文本中的标签系统，支持颜色、字体、大小、图片等多种格式

-- 使用druid内置的颜色系统（替代原来的rt_color模块）
local color = require("druid.color")

--- 模块主表，提供标签处理的核心功能
local M = {}
--- 标签注册表，存储所有支持的标签处理器
--- key: 标签名，value: 处理函数
local tags = {}


---应用指定的标签效果
---根据标签名查找对应的处理函数并执行
---@param tag string 标签名，如"color"、"size"、"font"等
---@param params string 标签参数，如FF0000、24px等
---@param table settings 富文本的设置表，将被修改
---@param table style 富文本的样式表
---@return boolean 是否成功应用标签效果
--- true表示标签存在并成功应用，false表示标签不存在
function M.apply(tag, params, settings, style)
	--- 从标签注册表中查找对应的处理函数
	local fn = tags[tag]
	--- 如果找不到对应的标签处理函数，返回失败
	if not fn then
		return false
	end

	--- 找到处理函数，调用它来应用标签效果
	--- 处理函数会修改settings参数，应用相应的样式
	fn(params, settings, style)
	--- 返回成功
	return true
end

---注册新的富文本标签处理器
---此函数允许用户自定义富文本支持的标签类型
---@param tag string 标签名称，如"color"、"bold"、"italic"等
---@param fn function 处理函数，接收参数(params, settings, style)
--- params: 标签参数
--- settings: 富文本设置表，处理器可以修改此表来应用样式
--- style: 富文本样式表
function M.register(tag, fn)
	--- 验证参数不为空
	assert(tag, "You must provide a tag")        -- 必须提供标签名
	assert(fn, "You must provide a tag function") -- 必须提供处理函数

	--- 将标签和处理函数注册到标签表中
	tags[tag] = fn
end

---字符串分割工具函数
---在第一次出现标记的位置分割字符串
---主要用于解析富文本标签的参数
---@param s string? 要分割的字符串
---@param token string 用于分割的标记/分隔符
---@return string? before 标记前的字符串部分，如果标记不存在则返回整个字符串
---@return string? after 标记后的字符串部分，如果标记不存在则返回nil
---@usage
--- local text, params = split("color=FF0000", "=")
--- text = "color", params = "FF0000"
local function split(s, token)
	--- 如果输入字符串为nil，返回两个nil
	if not s then return nil, nil end
	--- 使用Lua的模式匹配来分割字符串
	--- (.-) 匹配最短的任意字符（非贪婪模式）
	--- (.*) 匹配剩余的所有字符
	local before, after = s:match("(.-)" .. token .. "(.*)")
	--- 如果没有找到标记，返回整个字符串
	before = before or s
	--- 返回分割结果
	return before, after
end


---注册颜色标签处理器
---支持十六进制颜色值和颜色名称
---格式：<color=[#]{HEX_VALUE}>{Text}</color>
---格式：<color={COLOR_NAME}>{Text}</color>
---示例：<color=FF0000>红色文本</color>
---示例：<color=red>红色文本</color>
---@param params string 颜色参数，可以是十六进制值（FF0000）或颜色名称（red）
---@param settings table 富文本设置表，将被添加color字段
---@param style table 富文本样式表（本标签中未使用）
M.register("color", function(params, settings, style)
	--- 使用颜色模块获取标准化的颜色值
	--- 支持十六进制格式、颜色名称等多种格式
	settings.color = color.get_color(params)
end)


---注册文本阴影标签处理器
---为文本添加阴影效果
---格式：<color=shadow_color>文本</color>
---示例：<color=333333>阴影文本</color>
---@param params string 阴影颜色参数，可以是十六进制值或颜色名称
---@param settings table 富文本设置表，将被添加shadow字段
---@param style table 富文本样式表（本标签中未使用）
M.register("shadow", function(params, settings, style)
	--- 设置阴影颜色
	--- 注意：实际阴影效果可能需要额外的渲染支持
	settings.shadow = color.get_color(params)
end)


---注册文本轮廓标签处理器
---为文本添加轮廓描边效果
---格式：<outline=outline_color>文本</outline>
---示例：<outline=000000>描边文本</outline>
---@param params string 轮廓颜色参数，可以是十六进制值或颜色名称
---@param settings table 富文本设置表，将被添加outline字段
---@param style table 富文本样式表（本标签中未使用）
M.register("outline", function(params, settings, style)
	--- 设置轮廓颜色
	--- 注意：实际轮廓效果可能需要额外的渲染支持
	settings.outline = color.get_color(params)
end)


---注册字体标签处理器
---指定文本使用的字体
---格式：<font=font_name>文本</font>
---示例：<font=Roboto-Bold>粗体文本</font>
---@param params string 字体名称
---@param settings table 富文本设置表，将被添加font字段
---@param style table 富文本样式表（本标签中未使用）
M.register("font", function(params, settings)
	--- 直接设置字体名称
	--- 字体需要在项目中预加载
	settings.font = params
end)


---注册字体大小标签处理器
---设置文本的相对缩放大小
---格式：<size=scale_value>文本</size>
---示例：<size=1.5>大号文本</size>
---@param params string 缩放值，数字字符串（如"1.5"）
---@param settings table 富文本设置表，将被添加relative_scale字段
---@param style table 富文本样式表（本标签中未使用）
M.register("size", function(params, settings)
	--- 将参数转换为数字并设置为相对缩放
	--- 1.0表示原始大小，2.0表示放大两倍，0.5表示缩小一半
	settings.relative_scale = tonumber(params)
end)


---注册换行标签处理器
---强制文本换行
---格式：<br/>
---示例：<br/>
---@param params string 换行标签参数（本标签中未使用）
---@param settings table 富文本设置表，将被添加br字段
---@param style table 富文本样式表（本标签中未使用）
M.register("br", function(params, settings)
	--- 标记需要换行
	--- 这通常在富文本解析器遇到此标签时强制换行
	settings.br = true
end)


---注册不换行标签处理器
---强制文本不换行，即使超出容器宽度
---格式：<nobr>文本</nobr>
---示例：<nobr>这行文本不会被换行</nobr>
---@param params string 不换行标签参数（本标签中未使用）
---@param settings table 富文本设置表，将被添加nobr字段
---@param style table 富文本样式表（本标签中未使用）
M.register("nobr", function(params, settings)
	--- 标记为不换行文本
	--- 这告诉富文本渲染器不要在此处换行
	settings.nobr = true
end)


---注册图片标签处理器
---在富文本中嵌入图片
---格式：<img=texture_id:animation_id,width,height/>
---示例：<img=logo/>（使用默认大小）
---示例：<img=logo,48/>（48x48像素）
---示例：<img=my_texture:my_animation,100,50/>（指定尺寸）
---@param params string 图片参数，格式为"texture_id"或"texture_id:animation_id,width,height"
---@param settings table 富文本设置表，将被添加image字段
---@param style table 富文本样式表（本标签中未使用）
M.register("img", function(params, settings)
	--- 分割动画参数和尺寸参数
	--- 第一个分割：texture:anim 和 width,height
	local texture_and_anim, params = split(params, ",")
	--- 分割宽度和高度
	--- 第二个分割：width 和 height
	local width, height
	width, params = split(params, ",")
	height = split(params, ",")
	--- 分割纹理和动画名称
	--- 第三个分割：texture 和 anim
	local texture, anim = split(texture_and_anim, ":")
	--- 将尺寸参数转换为数字
	--- 如果没有提供宽度，则为nil
	width = width and tonumber(width)
	--- 如果没有提供高度，则使用宽度值（保持正方形）
	height = height and tonumber(height) or width

	--- 设置图片配置
	settings.image = {
		texture = texture,      -- 纹理ID
		anim = anim,            -- 动画名称（可选）
		width = width,          -- 图片宽度
		height = height or width, -- 图片高度（默认等于宽度）
	}
end)


return M
