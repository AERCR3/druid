# druid.slider API

> 位于 /druid/extended/slider.lua

基本的 Druid 滑块组件。创建一个可在直线上拖动的节点，并报告进度。

### 设置

使用 druid 创建滑块组件：`slider = druid:new_slider(node_name, end_pos, callback)`

### 注意事项

- 滑块节点应放置在零进度的初始位置
- 它将能够在起始位置和结束位置之间移动滑块节点
- 您可以通过 `slider:set_steps` 在滑块上设置兴趣点。如果存在步骤，滑块值将仅来自这些步骤（刻度滑块）
- 起始位置和结束位置应在垂直或水平线上（它们的 x 或 y 值应相等）
- 要在整个滑块上捕捉输入，您可以通过 `slider:set_input_node` 设置输入节点

## 函数

- [init](#init)
- [set](#set)
- [set_end_pos](#set_end_pos)
- [set_steps](#set_steps)
- [set_input_node](#set_input_node)
- [set_enabled](#set_enabled)
- [is_enabled](#is_enabled)

## 字段

- [node](#node)
- [on_change_value](#on_change_value)
- [style](#style)

### init

---

```lua
slider:init(node, end_pos, [callback])
```

滑块构造函数。

- **参数:**
  - `node` _(node)_: 作为滑块拖动的 GUI 节点
  - `end_pos` _(vector3)_: 滑块的结束位置，应与节点在同一轴上
  - `[callback]` _(function|nil)_: 滑块更改回调函数

### set

---

```lua
slider:set(value, [is_instant])
```

设置滑块值。

- **参数:**
  - `value` _(number)_: 滑块值（0-1）
  - `[is_instant]` _(boolean)_: 是否立即设置（无动画）

### set_end_pos

---

```lua
slider:set_end_pos(end_pos)
```

设置结束位置。

- **参数:**
  - `end_pos` _(vector3)_: 结束位置

### set_steps

---

```lua
slider:set_steps(steps)
```

设置滑块步进。

- **参数:**
  - `steps` _(table)_: 步进值数组

### set_input_node

---

```lua
slider:set_input_node(input_node)
```

设置输入节点。

- **参数:**
  - `input_node` _(node)_: 输入节点

### set_enabled

---

```lua
slider:set_enabled(enabled)
```

设置滑块是否启用。

- **参数:**
  - `enabled` _(boolean)_: 是否启用

### is_enabled

---

```lua
slider:is_enabled()
```

检查滑块是否启用。

- **返回:**
  - `enabled` _(boolean)_: 是否启用

## 事件字段

### node

滑块组件关联的节点。

### on_change_value

值更改时的回调函数。

### style

滑块组件样式配置。
