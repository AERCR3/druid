# druid.button API

> 位于 /druid/base/button.lua

基本的 Druid 输入组件。处理节点上的输入并在触摸事件上提供不同的回调。

### 设置

使用 druid 创建按钮：`button = druid:new_button(node_name, callback, [params], [animation_node])`
其中 node_name 是 GUI 场景中的节点名称。您可以使用 `node_name` 作为输入触发区域，并通过 `animation_node` 指向另一个节点进行动画

### 注意事项

- 按钮回调具有以下参数：(self, params, button_instance)
- - **self** - Druid 自身上下文
- - **params** - 在按钮创建时指定的附加参数
- - **button_instance** - 按钮本身
- 您可以在按钮创建时在按钮回调上设置*params*：`druid:new_button("node_name", callback, params)`。
- 按钮有几个事件，如 on_click、on_repeated_click、on_long_click、on_hold_click、on_double_click
- 如果按下和释放状态之间光标位于节点区域外，则点击事件不会触发
- 按钮可以有按键触发器，可以通过按键使用它们：`button:set_key_trigger`

## 函数

- [init](#init)
- [set_animations_disabled](#set_animations_disabled)
- [set_enabled](#set_enabled)
- [is_enabled](#is_enabled)
- [set_click_zone](#set_click_zone)
- [set_key_trigger](#set_key_trigger)
- [get_key_trigger](#get_key_trigger)
- [set_check_function](#set_check_function)
- [set_web_user_interaction](#set_web_user_interaction)
- [button_hover](#button_hover)
- [button_mouse_hover](#button_mouse_hover)
- [button_click](#button_click)
- [button_repeated_click](#button_repeated_click)
- [button_long_click](#button_long_click)
- [button_double_click](#button_double_click)
- [button_hold](#button_hold)

## 字段

- [on_click](#on_click)
- [on_pressed](#on_pressed)
- [on_repeated_click](#on_repeated_click)
- [on_long_click](#on_long_click)
- [on_double_click](#on_double_click)
- [on_hold_callback](#on_hold_callback)
- [on_click_outside](#on_click_outside)
- [node](#node)
- [node_id](#node_id)

### init

---

```lua
button.init(self, node, callback, [params], [animation_node])
```

按钮组件初始化。

- **参数:**
  - `self` _(druid.button)_: 按钮实例
  - `node` _(node)_: GUI 节点
  - `callback` _(function)_: 按钮回调函数
  - `[params]` _(any)_: 传递给回调函数的参数
  - `[animation_node]` _(node)_: 用于动画的节点

### set_animations_disabled

---

```lua
button.set_animations_disabled(disabled)
```

禁用/启用按钮动画。

- **参数:**
  - `disabled` _(boolean)_: 是否禁用动画

### set_enabled

---

```lua
button.set_enabled(enabled)
```

启用/禁用按钮。

- **参数:**
  - `enabled` _(boolean)_: 是否启用按钮

### is_enabled

---

```lua
button.is_enabled()
```

检查按钮是否启用。

- **返回:**
  - `enabled` _(boolean)_: 按钮是否启用

### set_click_zone

---

```lua
button.set_click_zone(zone_node)
```

设置按钮点击区域。

- **参数:**
  - `zone_node` _(node)_: 用作点击区域的节点

### set_key_trigger

---

```lua
button.set_key_trigger(key, [key_press_type])
```

设置按钮的按键触发器。

- **参数:**
  - `key` _(string)_: 按键名称
  - `[key_press_type]` _(string)_: 按键类型，默认为 "pressed"

### get_key_trigger

---

```lua
button.get_key_trigger()
```

获取按钮的按键触发器。

- **返回:**
  - `key_trigger` _(string)_: 按键触发器名称

### set_check_function

---

```lua
button.set_check_function(check_function)
```

设置按钮检查函数。

- **参数:**
  - `check_function` _(function)_: 检查函数

### set_web_user_interaction

---

```lua
button.set_web_user_interaction(enabled)
```

设置 Web 用户交互。

- **参数:**
  - `enabled` _(boolean)_: 是否启用 Web 用户交互

### button_hover

---

```lua
button.button_hover(is_hovered)
```

按钮悬停事件。

- **参数:**
  - `is_hovered` _(boolean)_: 是否悬停

### button_mouse_hover

---

```lua
button.button_mouse_hover(is_hovered)
```

按钮鼠标悬停事件。

- **参数:**
  - `is_hovered` _(boolean)_: 是否悬停

### button_click

---

```lua
button.button_click()
```

按钮点击事件。

### button_repeated_click

---

```lua
button.button_repeated_click()
```

按钮重复点击事件。

### button_long_click

---

```lua
button.button_long_click()
```

按钮长按事件。

### button_double_click

---

```lua
button.button_double_click()
```

按钮双击事件。

### button_hold

---

```lua
button.button_hold()
```

按钮持续按住事件。

## 事件字段

### on_click

点击事件回调。

### on_pressed

按下事件回调。

### on_repeated_click

重复点击事件回调。

### on_long_click

长按事件回调。

### on_double_click

双击事件回调。

### on_hold_callback

持续按住事件回调。

### on_click_outside

在按钮外部点击事件回调。

### node

按钮关联的 GUI 节点。

### node_id

按钮节点的 ID。
