--- Defold解析器配置文件
--- 定义了解析Defold资源文件所需的各种配置参数
local M = {}

--- 定义不应带引号的键集合
M.string_keys = {
	text = true,           -- 文本字段
	id = true,             -- ID字段
	value = true,          -- 值字段
	rename_patterns = true, -- 重命名模式字段
}


--- 始终作为列表处理的键
M.ALWAYS_LIST = {
	attributes = true,          -- 属性列表
	nodes = true,               -- 节点列表
	images = true,              -- 图像列表
	children = true,            -- 子节点列表
	fonts = true,               -- 字体列表
	layers = true,              -- 图层列表
	textures = true,            -- 纹理列表
	embedded_components = true, -- 嵌入组件列表
	embedded_instances = true,  -- 嵌入实例列表
	collection_instances = true, -- 集合实例列表
	instances = true,           -- 实例列表
}


--- 需要保留小数点的参数列表
--- 这些参数在输出时会保留一位小数
M.with_dot_params = {
	"x",                 -- X坐标
	"y",                 -- Y坐标
	"z",                 -- Z坐标
	"w",                 -- W坐标
	"alpha",             -- 透明度
	"outline_alpha",     -- 轮廓透明度
	"shadow_alpha",      -- 阴影透明度
	"text_leading",      -- 文本行距
	"text_tracking",     -- 文本字距
	"pieFillAngle",      -- 扇形填充角度
	"innerRadius",       -- 内半径
	"leading",           -- 行距
	"tracking",          -- 字距
	"data",              -- 数据
	"t_x",               -- 变换X坐标
	"t_y",               -- 变换Y坐标
	"spread",            -- 扩散
	"start_delay",       -- 开始延迟
	"inherit_velocity",  -- 继承速度
	"start_delay_spread", -- 开始延迟扩散
	"duration_spread",   -- 持续时间扩散
	"start_offset",      -- 开始偏移
	"outline_width",     -- 轮廓宽度
	"shadow_x",          -- 阴影X偏移
	"shadow_y",          -- 阴影Y偏移
	"aspect_ratio",      -- 宽高比
	"far_z",             -- 远平面Z值
	"mass",              -- 质量
	"linear_damping",    -- 线性阻尼
	"angular_damping",   -- 角度阻尼
	"gain",              -- 增益
	"pan",               -- 平移
	"speed",             -- 速度
	"duration"           -- 持续时间
}

--- 键排序规则
--- 定义不同资源类型的键排列顺序
M.KEY_ORDER = {
	["font"] = {        -- 字体资源的键排序
		"extrude_borders", -- 拉伸边框
		"images",         -- 图像
		"inner_padding",  -- 内边距
		"margin",         -- 外边距
		"font",           -- 字体
		"material",       -- 材质
		"size",           -- 尺寸
		"antialias",      -- 抗锯齿
		"alpha",          -- 透明度
		"outline_alpha",  -- 轮廓透明度
		"outline_width",  -- 轮廓宽度
		"shadow_alpha",   -- 阴影透明度
		"shadow_blur",    -- 阴影模糊
		"shadow_x",       -- 阴影X偏移
		"shadow_y",       -- 阴影Y偏移
		"extra_characters", -- 额外字符
		"output_format",  -- 输出格式
		"all_chars",      -- 所有字符
		"cache_width",    -- 缓存宽度
		"cache_height",   -- 缓存高度
		"render_mode",    -- 渲染模式
	},
	["atlas"] = {       -- 图集资源的键排序
		"id",             -- ID
		"images",         -- 图像
		"playback",       -- 播放
		"fps",            -- 帧率
		"flip_horizontal", -- 水平翻转
		"flip_vertical",  -- 垂直翻转
		"image",          -- 图像
		"sprite_trim_mode", -- 精灵裁剪模式
		"images",         -- 图像
		"animations",     -- 动画
		"margin",         -- 外边距
		"extrude_borders", -- 拉伸边框
		"inner_padding",
		"max_page_width",
		"max_page_height",
		"rename_patterns",
	},
	["gui"] = {
		"position",
		"rotation",
		"scale",
		"size",
		"color",
		"type",
		"blend_mode",
		"text",
		"texture",
		"font",
		"id",
		"xanchor",
		"yanchor",
		"pivot",
		"outline",
		"shadow",
		"adjust_mode",
		"line_break",
		"parent",
		"layer",
		"inherit_alpha",
		"slice9",
		"outerBounds",
		"innerRadius",
		"perimeterVertices",
		"pieFillAngle",
		"clipping_mode",
		"clipping_visible",
		"clipping_inverted",
		"alpha",
		"outline_alpha",
		"shadow_alpha",
		"overridden_fields",
		"template",
		"template_node_child",
		"text_leading",
		"text_tracking",
		"size_mode",
		"spine_scene",
		"spine_default_animation",
		"spine_skin",
		"spine_node_child",
		"particlefx",
		"custom_type",
		"enabled",
		"visible",

		-- Scene
		"scripts",
		"fonts",
		"textures",
		"background_color",
		"nodes",
		"layers",
		"material",
		"layouts",
		"adjust_reference",
		"max_nodes",
		"spine_scenes",
		"particlefxs",
		"resources",
		"materials",
		"max_dynamic_textures",

		-- Vectors
		"x",
		"y",
		"z",
		"w",
	},
}

return M
