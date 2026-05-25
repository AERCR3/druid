# 高级 Druid 设置

## 输入绑定

默认情况下，**Druid** 使用 Defold 默认的 `/builtins/input/all.input_binding` 中的所有键名进行输入绑定。

**Druid** 需要以下输入绑定：

- 鼠标触发器: `Button 1` -> `touch` (用于基本输入组件)
- 鼠标触发器: `Wheel up` -> `mouse_wheel_up` (用于滚动组件)
- 鼠标触发器: `Wheel down` -> `mouse_wheel_down` (用于滚动组件)
- 键盘触发器: `Backspace` -> `key_backspace` (用于返回处理器组件，输入组件)
- 键盘触发器: `Back` -> `key_back` (用于返回处理器组件，Android 返回键，输入组件)
- 键盘触发器: `Enter` -> `key_enter` (用于输入组件，可选)
- 键盘触发器: `Space` -> `key_space` (用于导航处理器小部件，可选)
- 键盘触发器: `Esc` -> `key_esc` (用于输入组件，可选)
- 键盘触发器: `Left` -> `key_left` (用于富输入组件，可选)
- 键盘触发器: `Right` -> `key_right` (用于富输入组件，可选)
- 键盘触发器: `Up` -> `key_up` (用于导航处理器小部件，可选)
- 键盘触发器: `Down` -> `key_down` (用于导航处理器小部件，可选)
- 键盘触发器: `Shift` -> `key_lshift` (用于富输入组件，可选)
- 键盘触发器: `Ctrl` -> `key_lctrl` (用于富输入组件，可选)
- 键盘触发器: `Super` -> `key_lsuper` (用于富输入组件，可选)
- 触摸触发器: `Touch multi` -> `touch_multi` (用于滚动组件)

![](../media/input_binding_2.png)
![](../media/input_binding_1.png)

## 更改键绑定

如果您需要使用自己的键绑定或键名，可以在您的 _game.project_ 文件中修改它们。

以下是键绑定的默认值：

```
[druid]
input_text = text
input_touch = touch
input_marked_text = marked_text
input_key_esc = key_esc
input_key_back = key_back
input_key_enter = key_enter
input_key_space = key_space
input_key_backspace = key_backspace
input_multitouch = touch_multi
input_scroll_up = mouse_wheel_up
input_scroll_down = mouse_wheel_down
input_key_left = key_left
input_key_right = key_right
input_key_up = key_up
input_key_down = key_down
input_key_lshift = key_lshift
input_key_lctrl = key_lctrl
input_key_lsuper = key_lsuper
```

## 输入捕获

默认情况下，**Druid** 在创建任何输入组件时会自动捕获输入焦点。因此，您不需要调用 `msg.post(".", "acquire_input_focus")`。

如果您不需要此行为，可以通过在 _game.project_ 文件中设置 `druid.no_auto_input` 字段来禁用它：

```
[druid]
no_auto_input = 1
```

## 设置声音函数

您可以设置声音函数来播放 Druid 组件中的声音。主要用于按钮的点击声。

```lua
local druid = require("druid.druid")

-- 回调函数应按名称播放声音: function(sound_id) ... end
druid.set_sound_function(function(sound_id)
    sound.play("/sounds#" .. sound_id)
end)
```

## 设置文本函数

您可以设置文本函数以根据语言环境ID获取本地化字符串。

```lua
local lang = require("lang.lang")
local druid = require("druid.druid")

-- 您可以使用 lang.txp 函数根据语言环境ID获取本地化字符串
druid.set_text_function(lang.txp)

-- 或带有您自己逻辑的自定义函数
druid.set_text_function(function(locale_id)
    return my_lang_table[locale_id] or locale_id
end)
```

## 设置默认样式

您可以为 Druid 组件设置默认样式。

```lua
-- 从 Druid 文件夹复制默认样式并根据需要修改
local my_custom_style = require("my.custom.style")
local druid = require("druid.druid")

druid.set_default_style(my_custom_style)
```

## 语言变化时

您可以设置语言更改时要调用的函数。

```lua
local lang = require("lang.lang")
local druid = require("druid.druid")

function M.next_language()
    lang.set_next_lang()
	-- 当游戏语言更改时，调用此函数以重新翻译所有 Druid 组件
    druid.on_language_change()
end
```

## 窗口回调

您可以设置窗口事件发生时要调用的函数。

```lua
local druid = require("druid.druid")

-- 初始化窗口监听器，将覆盖之前的窗口监听器
druid.init_window_listener()

-- 或在 window.set_listener 内部调用此函数

-- 回调函数应在窗口事件发生时调用: function(event) ... end
window.set_listener(function(self, event)
	druid.on_window_callback(event)
end)
```
