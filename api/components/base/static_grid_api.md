# druid.grid API

> 位于 /druid/base/static_grid.lua

用于管理网格中节点位置的组件，具有各种选项

## 函数

- [init](#init)
- [get_pos](#get_pos)
- [get_index](#get_index)
- [get_index_by_node](#get_index_by_node)
- [set_anchor](#set_anchor)
- [refresh](#refresh)
- [set_pivot](#set_pivot)
- [add](#add)
- [set_items](#set_items)
- [remove](#remove)
- [get_items_count](#get_items_count)
- [get_size](#get_size)
- [get_size_for](#get_size_for)
- [get_borders](#get_borders)
- [get_all_pos](#get_all_pos)
- [set_position_function](#set_position_function)
- [clear](#clear)
- [get_offset](#get_offset)
- [set_in_row](#set_in_row)
- [set_item_size](#set_item_size)
- [sort_nodes](#sort_nodes)

## 字段

- [on_add_item](#on_add_item)
- [on_remove_item](#on_remove_item)
- [on_change_items](#on_change_items)
- [on_clear](#on_clear)
- [on_update_positions](#on_update_positions)
- [parent](#parent)
- [nodes](#nodes)
- [first_index](#first_index)
- [last_index](#last_index)
- [anchor](#anchor)
- [pivot](#pivot)
- [node_size](#node_size)
- [border](#border)
- [in_row](#in_row)
- [style](#style)
- [node_pivot](#node_pivot)

### init

---

```lua
grid:init(parent_node, item_node, in_row)
```

网格组件初始化。

- **参数:**
  - `parent_node` _(node)_: 父节点
  - `item_node` _(node)_: 项目节点模板
  - `in_row` _(number)_: 每行项目数

### get_pos

---

```lua
grid:get_pos(index)
```

获取指定索引位置的坐标。

- **参数:**
  - `index` _(number)_: 项目索引

- **返回:**
  - `position` _(vector3)_: 位置坐标

### get_index

---

```lua
grid:get_index(x, y)
```

根据坐标获取项目索引。

- **参数:**
  - `x` _(number)_: X 坐标
  - `y` _(number)_: Y 坐标

- **返回:**
  - `index` _(number)_: 项目索引

### get_index_by_node

---

```lua
grid:get_index_by_node(node)
```

根据节点获取项目索引。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `index` _(number)_: 项目索引

### set_anchor

---

```lua
grid:set_anchor(anchor)
```

设置网格锚点。

- **参数:**
  - `anchor` _(string)_: 锚点类型

### refresh

---

```lua
grid:refresh()
```

刷新网格布局。

### set_pivot

---

```lua
grid:set_pivot(pivot)
```

设置网格支点。

- **参数:**
  - `pivot` _(string)_: 支点类型

### add

---

```lua
grid:add(node)
```

向网格添加节点。

- **参数:**
  - `node` _(node)_: 要添加的节点

### set_items

---

```lua
grid:set_items(nodes)
```

设置网格项目。

- **参数:**
  - `nodes` _(table)_: 节点数组

### remove

---

```lua
grid:remove(node)
```

从网格移除节点。

- **参数:**
  - `node` _(node)_: 要移除的节点

### get_items_count

---

```lua
grid:get_items_count()
```

获取项目数量。

- **返回:**
  - `count` _(number)_: 项目数量

### get_size

---

```lua
grid:get_size()
```

获取网格大小。

- **返回:**
  - `size` _(vector3)_: 网格大小

### get_size_for

---

```lua
grid:get_size_for(count)
```

获取指定项目数的网格大小。

- **参数:**
  - `count` _(number)_: 项目数量

- **返回:**
  - `size` _(vector3)_: 网格大小

### get_borders

---

```lua
grid:get_borders()
```

获取网格边界。

- **返回:**
  - `borders` _(table)_: 边界信息

### get_all_pos

---

```lua
grid:get_all_pos()
```

获取所有项目位置。

- **返回:**
  - `positions` _(table)_: 位置数组

### set_position_function

---

```lua
grid:set_position_function(func)
```

设置位置计算函数。

- **参数:**
  - `func` _(function)_: 位置计算函数

### clear

---

```lua
grid:clear()
```

清空网格。

### get_offset

---

```lua
grid:get_offset()
```

获取网格偏移。

- **返回:**
  - `offset` _(vector3)_: 网格偏移

### set_in_row

---

```lua
grid:set_in_row(in_row)
```

设置每行项目数。

- **参数:**
  - `in_row` _(number)_: 每行项目数

### set_item_size

---

```lua
grid:set_item_size(size)
```

设置项目大小。

- **参数:**
  - `size` _(vector3)_: 项目大小

### sort_nodes

---

```lua
grid:sort_nodes()
```

对节点进行排序。

## 事件字段

### on_add_item

添加项目时的回调函数。

### on_remove_item

移除项目时的回调函数。

### on_change_items

项目更改时的回调函数。

### on_clear

清空网格时的回调函数。

### on_update_positions

更新位置时的回调函数。

### parent

父节点。

### nodes

网格中的节点数组。

### first_index

第一个项目的索引。

### last_index

最后一个项目的索引。

### anchor

网格锚点。

### pivot

网格支点。

### node_size

节点大小。

### border

边界设置。

### in_row

每行项目数。

### style

网格样式配置。

### node_pivot

节点支点。
