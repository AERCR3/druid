# druid API

> 位于 /druid/druid.lua

Druid UI 框架的入口点。
在此处创建新的 Druid 实例并调整 Druid 设置。

## 函数

- [new](#new)
- [register](#register)
- [set_default_style](#set_default_style)
- [set_text_function](#set_text_function)
- [set_sound_function](#set_sound_function)
- [init_window_listener](#init_window_listener)
- [on_window_callback](#on_window_callback)
- [on_language_change](#on_language_change)
- [get_widget](#get_widget)
- [register_druid_as_widget](#register_druid_as_widget)
- [unregister_druid_as_widget](#unregister_druid_as_widget)
- [set_logger](#set_logger)
- [get_logger](#get_logger)

### new

---

```lua
druid.new(context, [style])
```

创建一个新的 Druid 实例用于创建 GUI 组件。

- **参数:**
  - `context` _(table)_: Druid 上下文。通常，这是 gui_script 的 self。它会被传递到所有 Druid 回调函数中。
  - `[style]` _(table|nil)_: Druid 样式表，用于覆盖此 Druid 实例的样式参数。

- **返回:**
  - `druid_instance` _(druid.instance)_: 新的 Druid 实例

### register

---

```lua
druid.register(name, module)
```

注册一个新的外部 Druid 组件。
注册组件只是创建 druid:new\_{name} 函数。
例如，如果你注册了一个名为 "my_component" 的组件，你可以使用 druid:new_my_component(...) 来创建它。
如果你有自己的不想在每个文件中都 require 的"基本"组件，这会很有用。
创建组件的默认方式是 `druid_instance:new(component_class, ...)`。

- **参数:**
  - `name` _(string)_: 模块名称
  - `module` _(table)_: 包含组件的 Lua 表

### set_default_style

---

```lua
druid.set_default_style(style)
```

为所有 Druid 实例设置默认样式。

- **参数:**
  - `style` _(table)_: 默认样式

### set_text_function

---

```lua
druid.set_text_function(callback)
```

为 LangText 组件设置文本函数。

- **参数:**
  - `callback` _(fun(text_id: string):string)_: 获取本地化文本的函数

### set_sound_function

---

```lua
druid.set_sound_function(callback)
```

设置声音函数以使组件能够播放声音。

- **参数:**
  - `callback` _(fun(sound_id: string))_: 声音播放回调函数

### init_window_listener

---

```lua
druid.init_window_listener()
```

初始化窗口监听器。

### on_window_callback

---

```lua
druid.on_window_callback(callback)
```

设置窗口回调函数。

- **参数:**
  - `callback` _(fun(action: string))_: 窗口回调函数

### on_language_change

---

```lua
druid.on_language_change(callback)
```

设置语言更改回调函数。

- **参数:**
  - `callback` _(fun())_: 语言更改时的回调函数

### get_widget

---

```lua
druid.get_widget(widget_id)
```

根据 ID 获取小部件实例。

- **参数:**
  - `widget_id` _(string)_: 小部件 ID

- **返回:**
  - `widget_instance` _(table|nil)_: 小部件实例或 nil（如果未找到）

### register_druid_as_widget

---

```lua
druid.register_druid_as_widget(name, widget)
```

将 Druid 实例注册为小部件。

- **参数:**
  - `name` _(string)_: 小部件名称
  - `widget` _(table)_: 小部件实例

### unregister_druid_as_widget

---

```lua
druid.unregister_druid_as_widget(name)
```

注销作为小部件的 Druid 实例。

- **参数:**
  - `name` _(string)_: 小部件名称

### set_logger

---

```lua
druid.set_logger(logger)
```

设置日志记录器。

- **参数:**
  - `logger` _(table)_: 日志记录器实例

### get_logger

---

```lua
druid.get_logger()
```

获取当前日志记录器。

- **返回:**
  - `logger` _(table)_: 日志记录器实例
