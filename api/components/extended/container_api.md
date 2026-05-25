# druid.container API

> 位于 /druid/extended/container.lua

Druid 组件，用于管理大小和位置与其他容器的关系，以创建可适应的布局。

### 设置

使用 druid 创建容器组件：`container = druid:new_container(node, mode, callback)`

### 注意事项

- 容器可用于创建响应窗口大小变化的可适应布局
- 容器支持不同的布局模式：FIT、STRETCH、STRETCH_X、STRETCH_Y
- 容器可以嵌套在其他容器内部
- 容器支持固定边距和基于百分比的大小调整
- 容器可以使用支点定位
- 容器支持最小尺寸约束
- 容器可以适配到窗口或自定义大小

## 函数

- [init](#init)
- [refresh_origins](#refresh_origins)
- [set_pivot](#set_pivot)
- [set_size](#set_size)
- [get_position](#get_position)
- [set_position](#set_position)
- [get_size](#get_size)
- [get_scale](#get_scale)
- [fit_into_size](#fit_into_size)
- [fit_into_window](#fit_into_window)
- [add_container](#add_container)
- [remove_container_by_node](#remove_container_by_node)
- [set_parent_container](#set_parent_container)
- [refresh](#refresh)
- [refresh_scale](#refresh_scale)
- [update_child_containers](#update_child_containers)
- [create_draggable_corners](#create_draggable_corners)
- [clear_draggable_corners](#clear_draggable_corners)
- [fit_into_node](#fit_into_node)
- [set_min_size](#set_min_size)
- [set_max_size](#set_max_size)

## 字段

- [node](#node)
- [druid](#druid)
- [node_offset](#node_offset)
- [origin_size](#origin_size)
- [size](#size)
- [origin_position](#origin_position)
- [position](#position)

### init

---

```lua
container:init(node, [params])
```

容器组件初始化。

- **参数:**
  - `node` _(node)_: GUI 节点
  - `[params]` _(table)_: 容器参数

### refresh_origins

---

```lua
container:refresh_origins()
```

刷新原始值。

### set_pivot

---

```lua
container:set_pivot(pivot)
```

设置支点。

- **参数:**
  - `pivot` _(string)_: 支点类型

### set_size

---

```lua
container:set_size(size)
```

设置大小。

- **参数:**
  - `size` _(vector3)_: 新大小

### get_position

---

```lua
container:get_position()
```

获取位置。

- **返回:**
  - `position` _(vector3)_: 当前位置

### set_position

---

```lua
container:set_position(position)
```

设置位置。

- **参数:**
  - `position` _(vector3)_: 新位置

### get_size

---

```lua
container:get_size()
```

获取大小。

- **返回:**
  - `size` _(vector3)_: 当前大小

### get_scale

---

```lua
container:get_scale()
```

获取缩放。

- **返回:**
  - `scale` _(vector3)_: 缩放向量

### fit_into_size

---

```lua
container:fit_into_size(size)
```

适配到指定大小。

- **参数:**
  - `size` _(vector3)_: 目标大小

### fit_into_window

---

```lua
container:fit_into_window()
```

适配到窗口大小。

### add_container

---

```lua
container:add_container(container)
```

添加子容器。

- **参数:**
  - `container` _(druid.container)_: 要添加的容器

### remove_container_by_node

---

```lua
container:remove_container_by_node(node)
```

通过节点移除容器。

- **参数:**
  - `node` _(node)_: 节点

### set_parent_container

---

```lua
container:set_parent_container(parent_container)
```

设置父容器。

- **参数:**
  - `parent_container` _(druid.container)_: 父容器

### refresh

---

```lua
container:refresh()
```

刷新容器。

### refresh_scale

---

```lua
container:refresh_scale()
```

刷新缩放。

### update_child_containers

---

```lua
container:update_child_containers()
```

更新子容器。

### create_draggable_corners

---

```lua
container:create_draggable_corners()
```

创建可拖动角落。

### clear_draggable_corners

---

```lua
container:clear_draggable_corners()
```

清除可拖动角落。

### fit_into_node

---

```lua
container:fit_into_node(node)
```

适配到节点大小。

- **参数:**
  - `node` _(node)_: 目标节点

### set_min_size

---

```lua
container:set_min_size(min_size)
```

设置最小大小。

- **参数:**
  - `min_size` _(vector3)_: 最小大小

### set_max_size

---

```lua
container:set_max_size(max_size)
```

设置最大大小。

- **参数:**
  - `max_size` _(vector3)_: 最大大小

## 事件字段

### node

容器组件关联的节点。

### druid

关联的 Druid 实例。

### node_offset

节点偏移。

### origin_size

原始大小。

### size

当前大小。

### origin_position

原始位置。

### position

当前位置。
