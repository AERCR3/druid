# 优化 Druid 大小

从 Druid 1.1 版本开始，现在所有组件都默认包含。这是为了简化 Druid 的使用并移除 `druid.register` 函数，该函数在使用未包含的组件时引发了大量问题。

这也意味着构建版本中 Druid 库的大小现在比以前稍大一些。虽然这对大多数用户来说不是问题，但对于那些不想使用大量 `extended` 组件且希望减少约 50kb 构建大小的用户，您可以从构建中剥离这些组件。

## 剥离组件

您需要下载并修改项目中的 Druid 库。要剥离未使用的组件，您需要编辑 `druid/system/druid_instance.lua` 文件。

例如，如果要剥离 `hotkey` 组件，您需要从 `M` 表中删除 `new_hotkey` 函数。

您需要删除这些行：

```lua
local hotkey = require("druid.extended.hotkey")
---创建热键组件
---@param keys_array string|string[] 触发动作的按键。应包含一个动作键和任意数量的修饰键
---@param callback function|nil 回调函数
---@param callback_argument any|nil 传递给回调函数的参数
---@return druid.hotkey component 热键组件
function M:new_hotkey(keys_array, callback, callback_argument)
	return self:new(hotkey, keys_array, callback, callback_argument)
end
```

就这样。现在 Druid 库将不再有任何指向 `hotkey` 组件的链接，构建大小将减少此组件的大小。

## 组件大小

这是 Druid 1.1 版本发布时 Druid 库中组件大小的表格。仅供参考。

| 组件           | 大小 (桌面) | 大小 (移动) |
| -------------- | ----------- | ----------- |
| `button`       | 4.36 kb     | 2.42 kb     |
| `text`         | 5.31 kb     | 2.90 kb     |
| `scroll`       | 8.27 kb     | 4.73 kb     |
| `grid`         | 5.97 kb     | 2.87 kb     |
| `blocker`      | 0.66 kb     | 0.45 kb     |
| `back_handler` | 0.57 kb     | 0.42 kb     |
| `hover`        | 2.31 kb     | 1.34 kb     |
| `drag`         | 3.73 kb     | 2.17 kb     |
| `progress`     | 2.76 kb     | 1.64 kb     |
| `slider`       | 2.67 kb     | 1.66 kb     |
| `swipe`        | 2.02 kb     | 1.23 kb     |
| `input`        | 5.59 kb     | 3.38 kb     |
| `timer`        | 1.47 kb     | 0.94 kb     |
| `layout`       | 4.96 kb     | 2.83 kb     |
| `lang_text`    | 1.10 kb     | 0.63 kb     |
| `hotkey`       | 2.29 kb     | 1.46 kb     |
| `data_list`    | 3.24 kb     | 1.81 kb     |
| `container`    | 6.86 kb     | 3.75 kb     |
| `rich_text`    | 13.24 kb    | 8.27 kb     |
| `rich_input`   | 4.16 kb     | 2.38 kb     |
