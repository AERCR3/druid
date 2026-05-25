# druid.hover API

> 位于 /druid/base/hover.lua

用于处理节点上悬停事件的组件

## 函数

- [init](#init)
- [set_hover](#set_hover)
- [is_hovered](#is_hovered)
- [set_mouse_hover](#set_mouse_hover)
- [is_mouse_hovered](#is_mouse_hovered)
- [set_click_zone](#set_click_zone)
- [set_enabled](#set_enabled)
- [is_enabled](#is_enabled)

## 字段

- [node](#node)
- [on_hover](#on_hover)
- [on_mouse_hover](#on_mouse_hover)
- [style](#style)
- [click_zone](#click_zone)

### init

---

```lua
hover:init(node, on_hover_callback, on_mouse_hover)
```

悬停组件的构造函数。

- **参数:**
  - `node` _(node)_: GUI 节点
  - `on_hover_callback` _(function)_: 悬停回调函数
  - `on_mouse_hover` _(function)_: 鼠标悬停回调函数

### set_hover

---

```lua
hover:set_hover([state])
```

设置悬停状态。

- **参数:**
  - `[state]` _(boolean)_: 悬停状态（true 为悬停，false 为非悬停，默认为 true）

### is_hovered

---

```lua
hover:is_hovered()
```

检查是否有触摸悬停。

- **返回:**
  - `hovered` _(boolean)_: 是否有触摸悬停

### set_mouse_hover

---

```lua
hover:set_mouse_hover([state])
```

设置鼠标悬停状态。

- **参数:**
  - `[state]` _(boolean)_: 鼠标悬停状态（true 为悬停，false 为非悬停，默认为 true）

### is_mouse_hovered

---

```lua
hover:is_mouse_hovered()
```

检查是否有鼠标悬停。

- **返回:**
  - `hovered` _(boolean)_: 是否有鼠标悬停

### set_click_zone

---

```lua
hover:set_click_zone(zone_node)
```

设置点击区域。

- **参数:**
  - `zone_node` _(node)_: 用作点击区域的节点

### set_enabled

---

```lua
hover:set_enabled(enabled)
```

设置组件是否启用。

- **参数:**
  - `enabled` _(boolean)_: 是否启用

### is_enabled

---

```lua
hover:is_enabled()
```

检查组件是否启用。

- **返回:**
  - `enabled` _(boolean)_: 是否启用

## 事件字段

### node

悬停组件关联的节点。

### on_hover

触摸悬停时的回调函数。

### on_mouse_hover

鼠标悬停时的回调函数。

### style

悬停组件样式配置。

### click_zone

点击区域节点。
