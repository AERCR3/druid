# druid.swipe API

> 位于 /druid/extended/swipe.lua

用于管理节点上滑动事件的组件

## 函数

- [init](#init)
- [set_click_zone](#set_click_zone)

## 字段

- [node](#node)
- [on_swipe](#on_swipe)
- [style](#style)
- [click_zone](#click_zone)

### init

---

```lua
swipe:init(node_or_node_id, on_swipe_callback)
```

- **参数:**
  - `node_or_node_id` _(string|node)_: 节点或节点ID
  - `on_swipe_callback` _(function)_: 滑动回调函数

### set_click_zone

---

```lua
swipe:set_click_zone([zone])
```

设置滑动的点击区域，对于限制模板节点外的事件很有用。

- **参数:**
  - `[zone]` _(string|node|nil)_: GUI 节点

## 事件字段

### node

用于管理滑动的节点。

### on_swipe

检测到滑动时触发的事件。
函数签名：fun(context, side, dist, dt)

### style

滑动组件样式配置。

### click_zone

点击区域节点。
