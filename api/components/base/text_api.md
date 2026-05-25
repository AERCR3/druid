# druid.text API

> 位于 /druid/base/text.lua

基本的 Druid 文本组件。文本组件默认具有文本大小调整功能。

### 设置

使用 druid 创建文本节点：`text = druid:new_text(node_name, [initial_value], [text_adjust_type])`

### 注意事项

- 文本组件默认具有自动调整文本大小的功能。文本永远不会比您在 GUI 场景中设置的文本节点大小更大。
- 文本支点可以用 `text:set_pivot` 更改，文本将在其文本大小框内保持其位置
- 有几种文本调整类型：
- - **"downscale"** - 更改文本的比例以适应文本节点大小（默认）
- - **"trim"** - 使用后缀（默认 - "..."）修剪文本以适应文本节点大小
- - **"no_adjust"** - 不做任何调整，像默认的 Defold 文本节点一样
- - **"downscale_limited"** - 更改文本的比例如下调整，但对文本比例有限制
- - **"scroll"** - 更改文本的支点以模拟在文本框中的滚动。与模板节点一起使用以获得更好的效果。
- - **"scale_then_scroll"** - 结合两种模式：首先是限制缩放，然后滚动
- - **"trim_left"** - 使用后缀（默认 - "..."）修剪文本以适应文本节点大小
- - **"scale_then_trim"** - 结合两种模式：首先是限制缩放，然后修剪
- - **"scale_then_trim_left"** - 结合两种模式：首先是限制缩放，然后左修剪

## 函数

- [init](#init)
- [get_text_size](#get_text_size)
- [get_text_index_by_width](#get_text_index_by_width)
- [set_to](#set_to)
- [set_text](#set_text)
- [get_text](#get_text)
- [set_size](#set_size)
- [set_color](#set_color)
- [set_alpha](#set_alpha)
- [set_scale](#set_scale)
- [set_pivot](#set_pivot)
- [is_multiline](#is_multiline)
- [set_text_adjust](#set_text_adjust)
- [set_minimal_scale](#set_minimal_scale)
- [get_text_adjust](#get_text_adjust)

## 字段

- [node](#node)
- [on_set_text](#on_set_text)
- [on_update_text_scale](#on_update_text_scale)
- [on_set_pivot](#on_set_pivot)
- [style](#style)
- [start_pivot](#start_pivot)
- [start_scale](#start_scale)
- [scale](#scale)

### init

---

```lua
text.init(self, node, [initial_text], [adjust_type])
```

文本组件初始化。

- **参数:**
  - `self` _(druid.text)_: 文本实例
  - `node` _(node)_: GUI 节点
  - `[initial_text]` _(string)_: 初始文本
  - `[adjust_type]` _(string)_: 文本调整类型

### get_text_size

---

```lua
text.get_text_size()
```

获取文本的实际大小。

- **返回:**
  - `size` _(vector3)_: 文本的实际大小

### get_text_index_by_width

---

```lua
text.get_text_index_by_width(width)
```

根据指定宽度获取文本索引。

- **参数:**
  - `width` _(number)_: 指定的宽度

- **返回:**
  - `index` _(number)_: 文本索引

### set_to

---

```lua
text.set_to(value)
```

设置文本内容。

- **参数:**
  - `value` _(string)_: 文本值

### set_text

---

```lua
text.set_text(text_value)
```

设置文本内容。

- **参数:**
  - `text_value` _(string)_: 文本值

### get_text

---

```lua
text.get_text()
```

获取文本内容。

- **返回:**
  - `text` _(string)_: 当前文本内容

### set_size

---

```lua
text.set_size(size)
```

设置文本节点大小。

- **参数:**
  - `size` _(vector3)_: 新大小

### set_color

---

```lua
text.set_color(color)
```

设置文本颜色。

- **参数:**
  - `color` _(vector4)_: 颜色向量

### set_alpha

---

```lua
text.set_alpha(alpha)
```

设置文本透明度。

- **参数:**
  - `alpha` _(number)_: 透明度值

### set_scale

---

```lua
text.set_scale(scale)
```

设置文本缩放。

- **参数:**
  - `scale` _(vector3)_: 缩放向量

### set_pivot

---

```lua
text.set_pivot(pivot)
```

设置文本支点。

- **参数:**
  - `pivot` _(string|vector3)_: 支点类型或向量

### is_multiline

---

```lua
text.is_multiline()
```

检查文本是否为多行。

- **返回:**
  - `is_multiline` _(boolean)_: 是否为多行文本

### set_text_adjust

---

```lua
text.set_text_adjust(adjust_type)
```

设置文本调整类型。

- **参数:**
  - `adjust_type` _(string)_: 文本调整类型

### set_minimal_scale

---

```lua
text.set_minimal_scale(min_scale)
```

设置最小缩放比例。

- **参数:**
  - `min_scale` _(number)_: 最小缩放比例

### get_text_adjust

---

```lua
text.get_text_adjust()
```

获取当前文本调整类型。

- **返回:**
  - `adjust_type` _(string)_: 当前文本调整类型

## 事件字段

### node

文本组件关联的 GUI 节点。

### on_set_text

设置文本时的回调函数。

### on_update_text_scale

更新文本缩放时的回调函数。

### on_set_pivot

设置支点时的回调函数。

### style

文本样式配置。

### start_pivot

初始支点。

### start_scale

初始缩放。

### scale

当前缩放。
