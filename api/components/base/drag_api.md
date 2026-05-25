# druid.drag API

> 位于 /druid/base/drag.lua

一个允许您订阅节点上拖动事件的组件

## 函数

- [init](#init)
- [set_drag_cursors](#set_drag_cursors)
- [set_click_zone](#set_click_zone)
- [set_enabled](#set_enabled)
- [is_enabled](#is_enabled)

## 字段

- [node](#node)
- [on_touch_start](#on_touch_start)
- [on_touch_end](#on_touch_end)
- [on_drag_start](#on_drag_start)
- [on_drag](#on_drag)
- [on_drag_end](#on_drag_end)
- [style](#style)
- [click_zone](#click_zone)
- [is_touch](#is_touch)
- [is_drag](#is_drag)
- [can_x](#can_x)
- [can_y](#can_y)
- [dx](#dx)
- [dy](#dy)
- [touch_id](#touch_id)
- [x](#x)
- [y](#y)
- [screen_x](#screen_x)
- [screen_y](#screen_y)
- [touch_start_pos](#touch_start_pos)
- [druid](#druid)
- [hover](#hover)

### init

---

```lua
drag:init(node_or_node_id, [on_drag_callback])
```

拖动组件的构造函数。

- **参数:**
  - `node_or_node_id` _(node|string)_: GUI 节点或节点 ID
  - `[on_drag_callback]` _(function)_: 拖动回调函数

### set_drag_cursors

---

```lua
drag:set_drag_cursors(cursors)
```

设置拖动光标。

- **参数:**
  - `cursors` _(table)_: 光标配置表

### set_click_zone

---

```lua
drag:set_click_zone(zone_node)
```

设置点击区域。

- **参数:**
  - `zone_node` _(node)_: 用作点击区域的节点

### set_enabled

---

```lua
drag:set_enabled(enabled)
```

设置组件是否启用。

- **参数:**
  - `enabled` _(boolean)_: 是否启用

### is_enabled

---

```lua
drag:is_enabled()
```

检查组件是否启用。

- **返回:**
  - `enabled` _(boolean)_: 是否启用

## 事件字段

### node

拖动组件关联的节点。

### on_touch_start

触摸开始时的回调函数。

### on_touch_end

触摸结束时的回调函数。

### on_drag_start

拖动开始时的回调函数。

### on_drag

拖动过程中的回调函数。

### on_drag_end

拖动结束时的回调函数。

### style

拖动组件样式配置。

### click_zone

点击区域节点。

### is_touch

是否正在触摸。

### is_drag

是否正在拖动。

### can_x

是否可以在 X 轴上拖动。

### can_y

是否可以在 Y 轴上拖动。

### dx

X 轴拖动距离。

### dy

Y 轴拖动距离。

### touch_id

触摸 ID。

### x

当前 X 坐标。

### y

当前 Y 坐标。

### screen_x

屏幕 X 坐标。

### screen_y

屏幕 Y 坐标。

### touch_start_pos

触摸开始位置。

### druid

关联的 Druid 实例。

### hover

悬停组件引用。
