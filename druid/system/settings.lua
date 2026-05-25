---Druid系统设置类，管理本地化文本和声音播放等功能
---@class druid.system.settings
local M = {}

M.default_style = nil

---获取本地化文本
---此函数根据文本ID获取相应的本地化文本，支持字符串格式化参数
---@param text_id string 文本ID
---@param ... string string.format的可选参数
function M.get_text(text_id, ...)
	return "[Druid]: locales not inited"
end

---播放声音
---根据声音ID播放对应的声音效果
---@param sound_id string 声音ID
function M.play_sound(sound_id)
end

return M
