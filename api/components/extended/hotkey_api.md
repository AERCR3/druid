# druid.hotkey API

> 位于 /druid/extended/hotkey.lua

Druid 组件，用于管理热键并在按下热键时触发回调。

### 设置

使用 druid 创建热键组件：`hotkey = druid:new_hotkey(keys, callback, callback_argument)`

### 注意事项

- 热键可以通过按下单个键或组合键来触发
- 热键支持修饰键（例如 Ctrl、Shift、Alt）
- 热键可以在按键按下、释放或重复时触发
- 热键可以在运行时添加或删除
- 热键可以启用或禁用
- 热键可以设置为在按键按住时重复

## 函数

- [init](#init)
- [add_hotkey](#add_hotkey)
- [is_processing](#is_processing)
- [set_repeat](#set_repeat)
- [bind_node](#bind_node)

## 字段

- [on_hotkey_pressed](#on_hotkey_pressed)
- [on_hotkey_released](#on_hotkey_released)
- [style](#style)
- [druid](#druid)

### init

---

```lua
hotkey:init(keys, callback, [callback_argument])
```

热键构造函数。

- **参数:**
  - `keys` _(string|string[])_: 触发回调要按下的键。应该包含一个键和任意修饰键
  - `callback` _(function)_: 回调函数
  - `[callback_argument]` _(any)_: 传递给回调函数的参数

### add_hotkey

---

```lua
hotkey:add_hotkey(keys, callback, [callback_argument])
```

添加热键。

- **参数:**
  - `keys` _(string|string[])_: 要按下的键
  - `callback` _(function)_: 回调函数
  - `[callback_argument]` _(any)_: 传递给回调函数的参数

### is_processing

---

```lua
hotkey:is_processing()
```

检查是否正在处理热键。

- **返回:**
  - `processing` _(boolean)_: 是否正在处理

### set_repeat

---

```lua
hotkey:set_repeat(repeat_enabled)
```

设置重复。

- **参数:**
  - `repeat_enabled` _(boolean)_: 是否启用重复

### bind_node

---

```lua
hotkey:bind_node(node)
```

绑定节点。

- **参数:**
  - `node` _(node)_: 要绑定的节点

## 事件字段

### on_hotkey_pressed

热键按下时的回调函数。

### on_hotkey_released

热键释放时的回调函数。

### style

热键组件样式配置。

### druid

关联的 Druid 实例。
