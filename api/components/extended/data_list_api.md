# druid.data_list API

> 位于 /druid/extended/data_list.lua

Druid 组件，用于管理带有可滚动视图的数据列表，用于管理大量列表数据并仅渲染可见元素。

### 设置

使用 druid 创建数据列表组件：`data_list = druid:new_data_list(scroll, grid, create_function)`

### 注意事项

- 数据列表使用滚动组件进行滚动，使用网格组件进行布局
- 数据列表仅渲染可见元素以提高性能
- 数据列表支持元素缓存以提高性能
- 数据列表支持添加、删除和更新元素
- 数据列表支持滚动到特定元素
- 数据列表支持自定义元素创建和清理

## 函数

- [init](#init)
- [set_use_cache](#set_use_cache)
- [set_data](#set_data)
- [get_data](#get_data)
- [add](#add)
- [remove](#remove)
- [remove_by_data](#remove_by_data)
- [clear](#clear)
- [get_index](#get_index)
- [get_created_nodes](#get_created_nodes)
- [get_created_components](#get_created_components)
- [scroll_to_index](#scroll_to_index)

## 字段

- [scroll](#scroll)
- [grid](#grid)
- [on_scroll_progress_change](#on_scroll_progress_change)
- [on_element_add](#on_element_add)
- [on_element_remove](#on_element_remove)
- [top_index](#top_index)
- [last_index](#last_index)
- [scroll_progress](#scroll_progress)

### init

---

```lua
data_list:init(scroll, grid, create_function)
```

数据列表组件初始化。

- **参数:**
  - `scroll` _(druid.scroll)_: 滚动组件
  - `grid` _(druid.grid)_: 网格组件
  - `create_function` _(function)_: 元素创建函数

### set_use_cache

---

```lua
data_list:set_use_cache(use_cache)
```

设置是否使用缓存。

- **参数:**
  - `use_cache` _(boolean)_: 是否使用缓存

### set_data

---

```lua
data_list:set_data(data)
```

设置数据列表。

- **参数:**
  - `data` _(table)_: 数据列表

### get_data

---

```lua
data_list:get_data()
```

获取数据列表。

- **返回:**
  - `data` _(table)_: 数据列表

### add

---

```lua
data_list:add(item_data)
```

添加数据项。

- **参数:**
  - `item_data` _(any)_: 项目数据

### remove

---

```lua
data_list:remove(index)
```

按索引移除数据项。

- **参数:**
  - `index` _(number)_: 索引

### remove_by_data

---

```lua
data_list:remove_by_data(data)
```

按数据移除数据项。

- **参数:**
  - `data` _(any)_: 要移除的数据

### clear

---

```lua
data_list:clear()
```

清空数据列表。

### get_index

---

```lua
data_list:get_index(data)
```

根据数据获取索引。

- **参数:**
  - `data` _(any)_: 数据

- **返回:**
  - `index` _(number)_: 索引

### get_created_nodes

---

```lua
data_list:get_created_nodes()
```

获取已创建的节点。

- **返回:**
  - `nodes` _(table)_: 节点列表

### get_created_components

---

```lua
data_list:get_created_components()
```

获取已创建的组件。

- **返回:**
  - `components` _(table)_: 组件列表

### scroll_to_index

---

```lua
data_list:scroll_to_index(index)
```

滚动到指定索引。

- **参数:**
  - `index` _(number)_: 索引

## 事件字段

### scroll

滚动组件引用。

### grid

网格组件引用。

### on_scroll_progress_change

滚动进度更改时的回调函数。

### on_element_add

元素添加时的回调函数。

### on_element_remove

元素移除时的回调函数。

### top_index

顶部索引。

### last_index

最后索引。

### scroll_progress

滚动进度。
