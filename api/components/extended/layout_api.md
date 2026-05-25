# druid.layout API

> 位于 /druid/extended/layout.lua

Druid 组件，用于管理节点布局，将它们放置在节点大小内，同时考虑每个节点的大小和支点。

### 设置

使用 druid 创建布局组件：`layout = druid:new_layout(node, layout_type)`

### 注意事项

- 布局可以是水平、垂直或带换行的水平布局
- 布局可以调整父节点大小以适应内容
- 布局可以对齐内容
- 布局支持边距和内边距
- 添加或删除节点时，布局会自动更新
- 可以通过调用 set_dirty() 手动更新布局

## 函数

- [init](#init)
- [update](#update)
- [get_entities](#get_entities)
- [get_entities_count](#get_entities_count)
- [set_node_index](#set_node_index)
- [set_margin](#set_margin)
- [set_padding](#set_padding)
- [set_dirty](#set_dirty)
- [set_justify](#set_justify)
- [set_type](#set_type)
- [set_hug_content](#set_hug_content)
- [add](#add)
- [remove](#remove)
- [get_size](#get_size)
- [get_content_size](#get_content_size)
- [refresh_layout](#refresh_layout)
- [clear_layout](#clear_layout)
- [get_node_size](#get_node_size)
- [calculate_rows_data](#calculate_rows_data)
- [set_node_position](#set_node_position)
- [set_position_function](#set_position_function)

## 字段

- [node](#node)
- [rows_data](#rows_data)
- [is_dirty](#is_dirty)
- [entities](#entities)
- [margin](#margin)
- [padding](#padding)
- [type](#type)
- [is_resize_width](#is_resize_width)

### init

---

```lua
layout:init(node, [params])
```

布局组件初始化。

- **参数:**
  - `node` _(node)_: 父节点
  - `[params]` _(table)_: 布局参数

### update

---

```lua
layout:update(dt)
```

更新布局。

- **参数:**
  - `dt` _(number)_: 时间增量

### get_entities

---

```lua
layout:get_entities()
```

获取实体列表。

- **返回:**
  - `entities` _(table)_: 实体列表

### get_entities_count

---

```lua
layout:get_entities_count()
```

获取实体数量。

- **返回:**
  - `count` _(number)_: 实体数量

### set_node_index

---

```lua
layout:set_node_index(node, index)
```

设置节点索引。

- **参数:**
  - `node` _(node)_: 节点
  - `index` _(number)_: 索引

### set_margin

---

```lua
layout:set_margin(margin)
```

设置边距。

- **参数:**
  - `margin` _(number|vector4)_: 边距值

### set_padding

---

```lua
layout:set_padding(padding)
```

设置内边距。

- **参数:**
  - `padding` _(number|vector4)_: 内边距值

### set_dirty

---

```lua
layout:set_dirty()
```

设置布局为脏状态，强制重新计算。

### set_justify

---

```lua
layout:set_justify(justify)
```

设置对齐方式。

- **参数:**
  - `justify` _(string)_: 对齐方式

### set_type

---

```lua
layout:set_type(type)
```

设置布局类型。

- **参数:**
  - `type` _(string)_: 布局类型

### set_hug_content

---

```lua
layout:set_hug_content(hug_content)
```

设置是否紧密贴合内容。

- **参数:**
  - `hug_content` _(boolean)_: 是否紧密贴合内容

### add

---

```lua
layout:add(node)
```

添加节点到布局。

- **参数:**
  - `node` _(node)_: 要添加的节点

### remove

---

```lua
layout:remove(node)
```

从布局中移除节点。

- **参数:**
  - `node` _(node)_: 要移除的节点

### get_size

---

```lua
layout:get_size()
```

获取布局大小。

- **返回:**
  - `size` _(vector3)_: 布局大小

### get_content_size

---

```lua
layout:get_content_size()
```

获取内容大小。

- **返回:**
  - `size` _(vector3)_: 内容大小

### refresh_layout

---

```lua
layout:refresh_layout()
```

刷新布局。

### clear_layout

---

```lua
layout:clear_layout()
```

清除布局。

### get_node_size

---

```lua
layout:get_node_size(node)
```

获取节点大小。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `size` _(vector3)_: 节点大小

### calculate_rows_data

---

```lua
layout:calculate_rows_data()
```

计算行数据。

### set_node_position

---

```lua
layout:set_node_position(node, position)
```

设置节点位置。

- **参数:**
  - `node` _(node)_: 节点
  - `position` _(vector3)_: 位置

### set_position_function

---

```lua
layout:set_position_function(func)
```

设置位置计算函数。

- **参数:**
  - `func` _(function)_: 位置计算函数

## 事件字段

### node

布局组件关联的节点。

### rows_data

行数据信息。

### is_dirty

布局是否为脏状态（需要重新计算）。

### entities

布局中的实体列表。

### margin

边距设置。

### padding

内边距设置。

### type

布局类型。

### is_resize_width

是否调整宽度。
