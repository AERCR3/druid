# druid.scroll API

> 位于 /druid/base/scroll.lua

基本的 Druid 滚动组件。处理 Druid GUI 中的所有滚动行为。

### 设置

使用 druid 创建滚动组件：`druid:new_scroll(view_node, content_node)`

### 注意事项

- View_node 是捕获用户输入并识别滚动触摸的静态部分
- Content_node 是动态部分，将根据滚动系统改变位置
- 初始滚动大小将等于 content_node 大小
- 初始视图框将等于 view_node 大小
- 滚动默认样式具有惯性和拉伸效果的额外大小
- 您可以设置"兴趣点"以使滚动始终居中到最近的点
- 滚动事件：
- - on_scroll(self, position): 滚动移动回调
- - on_scroll_to(self, position, is_instant): scroll_to 函数回调
- - on_point_scroll(self, item_index, position): scroll_to_index 函数回调
- 滚动需要多点触控。滚动在拖动过程中正确处理触摸 ID 交换

## 函数

- [init](#init)
- [scroll_to](#scroll_to)
- [scroll_to_make_node_visible](#scroll_to_make_node_visible)
- [scroll_to_index](#scroll_to_index)
- [scroll_to_percent](#scroll_to_percent)
- [get_percent](#get_percent)
- [set_size](#set_size)
- [set_view_size](#set_view_size)
- [update_view_size](#update_view_size)
- [set_inert](#set_inert)
- [is_inert](#is_inert)
- [set_extra_stretch_size](#set_extra_stretch_size)
- [get_scroll_size](#get_scroll_size)
- [set_points](#set_points)
- [set_horizontal_scroll](#set_horizontal_scroll)
- [set_vertical_scroll](#set_vertical_scroll)
- [is_node_in_view](#is_node_in_view)
- [bind_grid](#bind_grid)
- [bind_layout](#bind_layout)
- [set_click_zone](#set_click_zone)

## 字段

- [node](#node)
- [click_zone](#click_zone)
- [on_scroll](#on_scroll)
- [on_scroll_to](#on_scroll_to)

### init

---

```lua
scroll.init(self, view_node, content_node, [params])
```

滚动组件初始化。

- **参数:**
  - `self` _(druid.scroll)_: 滚动实例
  - `view_node` _(node)_: 视图节点
  - `content_node` _(node)_: 内容节点
  - `[params]` _(table)_: 滚动参数

### scroll_to

---

```lua
scroll.scroll_to(position, [is_instant])
```

滚动到指定位置。

- **参数:**
  - `position` _(vector3)_: 目标位置
  - `[is_instant]` _(boolean)_: 是否立即滚动（无动画）

### scroll_to_make_node_visible

---

```lua
scroll.scroll_to_make_node_visible(node)
```

滚动以使指定节点可见。

- **参数:**
  - `node` _(node)_: 要使其可见的节点

### scroll_to_index

---

```lua
scroll.scroll_to_index(index)
```

滚动到指定索引位置。

- **参数:**
  - `index` _(number)_: 索引位置

### scroll_to_percent

---

```lua
scroll.scroll_to_percent(percent)
```

滚动到指定百分比位置。

- **参数:**
  - `percent` _(number)_: 百分比位置（0-1）

### get_percent

---

```lua
scroll.get_percent()
```

获取当前滚动百分比。

- **返回:**
  - `percent` _(number)_: 当前滚动百分比（0-1）

### set_size

---

```lua
scroll.set_size(size)
```

设置滚动内容大小。

- **参数:**
  - `size` _(vector3)_: 新的内容大小

### set_view_size

---

```lua
scroll.set_view_size(size)
```

设置视图大小。

- **参数:**
  - `size` _(vector3)_: 新的视图大小

### update_view_size

---

```lua
scroll.update_view_size()
```

更新视图大小。

### set_inert

---

```lua
scroll.set_inert(inert)
```

设置惯性。

- **参数:**
  - `inert` _(boolean)_: 是否启用惯性

### is_inert

---

```lua
scroll.is_inert()
```

检查是否启用了惯性。

- **返回:**
  - `inert` _(boolean)_: 是否启用了惯性

### set_extra_stretch_size

---

```lua
scroll.set_extra_stretch_size(extra_size)
```

设置额外拉伸大小。

- **参数:**
  - `extra_size` _(number)_: 额外拉伸大小

### get_scroll_size

---

```lua
scroll.get_scroll_size()
```

获取滚动内容大小。

- **返回:**
  - `size` _(vector3)_: 滚动内容大小

### set_points

---

```lua
scroll.set_points(points)
```

设置滚动点。

- **参数:**
  - `points` _(table)_: 滚动点数组

### set_horizontal_scroll

---

```lua
scroll.set_horizontal_scroll(enabled)
```

设置水平滚动。

- **参数:**
  - `enabled` _(boolean)_: 是否启用水平滚动

### set_vertical_scroll

---

```lua
scroll.set_vertical_scroll(enabled)
```

设置垂直滚动。

- **参数:**
  - `enabled` _(boolean)_: 是否启用垂直滚动

### is_node_in_view

---

```lua
scroll.is_node_in_view(node)
```

检查节点是否在视图中。

- **参数:**
  - `node` _(node)_: 要检查的节点

- **返回:**
  - `visible` _(boolean)_: 节点是否在视图中

### bind_grid

---

```lua
scroll.bind_grid(grid)
```

绑定网格组件。

- **参数:**
  - `grid` _(druid.grid)_: 网格组件

### bind_layout

---

```lua
scroll.bind_layout(layout)
```

绑定布局组件。

- **参数:**
  - `layout` _(druid.layout)_: 布局组件

### set_click_zone

---

```lua
scroll.set_click_zone(zone_node)
```

设置点击区域。

- **参数:**
  - `zone_node` _(node)_: 用作点击区域的节点

## 事件字段

### node

滚动组件关联的节点。

### click_zone

点击区域节点。

### on_scroll

滚动时的回调函数。

### on_scroll_to

滚动到位置时的回调函数。
