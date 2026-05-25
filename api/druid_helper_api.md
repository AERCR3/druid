# druid.helper API

> 位于 /druid/helper.lua

辅助模块包含在 Druid 库中使用的各种函数。
您也可以在自己的项目中使用这些函数。

## 函数

- [centrate_text_with_icon](#centrate_text_with_icon)
- [centrate_icon_with_text](#centrate_icon_with_text)
- [centrate_nodes](#centrate_nodes)
- [get_node](#get_node)
- [get_screen_aspect_koef](#get_screen_aspect_koef)
- [get_gui_scale](#get_gui_scale)
- [step](#step)
- [clamp](#clamp)
- [distance](#distance)
- [sign](#sign)
- [round](#round)
- [lerp](#lerp)
- [contains](#contains)
- [deepcopy](#deepcopy)
- [add_array](#add_array)
- [pick_node](#pick_node)
- [get_scaled_size](#get_scaled_size)
- [get_scene_scale](#get_scene_scale)
- [get_closest_stencil_node](#get_closest_stencil_node)
- [get_pivot_offset](#get_pivot_offset)
- [is_desktop](#is_desktop)
- [is_mobile](#is_mobile)
- [is_web](#is_web)
- [is_web_mobile](#is_web_mobile)
- [is_multitouch_supported](#is_multitouch_supported)
- [table_to_string](#table_to_string)
- [get_border](#get_border)
- [get_text_metrics_from_node](#get_text_metrics_from_node)
- [insert_with_shift](#insert_with_shift)
- [remove_with_shift](#remove_with_shift)
- [get_full_position](#get_full_position)
- [get_animation_data_from_node](#get_animation_data_from_node)

### centrate_text_with_icon

---

```lua
helper.centrate_text_with_icon([text_node], [icon_node], margin)
```

居中对齐两个节点。
节点将在 x=0 位置居中对齐
text_node 将排在第一位（左侧）

- **参数:**
  - `[text_node]` _(node|nil)_: GUI 文本节点
  - `[icon_node]` _(node|nil)_: GUI 盒子节点
  - `margin` _(number)_: 节点之间的偏移量

- **返回:**
  - `width` _(number)_: 居中元素的总宽度

### centrate_icon_with_text

---

```lua
helper.centrate_icon_with_text([icon_node], [text_node], [margin])
```

居中对齐两个节点。
节点将在 x=0 位置居中对齐
icon_node 将排在第一位（左侧）

- **参数:**
  - `[icon_node]` _(node|nil)_: GUI 盒子节点
  - `[text_node]` _(node|nil)_: GUI 文本节点
  - `[margin]` _(number|nil)_: 节点之间的偏移量

- **返回:**
  - `width` _(number)_: 居中元素的总宽度

### centrate_nodes

---

```lua
helper.centrate_nodes([margin], ...)
```

根据 x 位置和边距居中对齐节点。
此函数计算节点的总宽度并为每个节点设置位置。
居中将围绕 x=0 位置进行。

- **参数:**
  - `[margin]` _(number|nil)_: 节点之间的偏移量
  - `...` _(...)_: 可变参数

- **返回:**
  - `width` _(number)_: 居中元素的总宽度

### get_node

---

```lua
helper.get_node(node_id)
```

通过 ID 获取 GUI 节点。

- **参数:**
  - `node_id` _(string|node)_: 节点 ID 或节点本身

- **返回:**
  - `node` _(node)_: GUI 节点

### get_screen_aspect_koef

---

```lua
helper.get_screen_aspect_koef()
```

获取屏幕宽高比系数。

- **返回:**
  - `koef` _(number)_: 屏幕宽高比系数

### get_gui_scale

---

```lua
helper.get_gui_scale()
```

获取 GUI 缩放比例。

- **返回:**
  - `scale` _(vector3)_: GUI 缩放向量

### step

---

```lua
helper.step(edge, x)
```

步进函数。如果 x 大于等于 edge 则返回 1，否则返回 0。

- **参数:**
  - `edge` _(number)_: 边界值
  - `x` _(number)_: 输入值

- **返回:**
  - `result` _(number)_: 步进结果

### clamp

---

```lua
helper.clamp(value, min_value, max_value)
```

将值限制在指定范围内。

- **参数:**
  - `value` _(number)_: 要限制的值
  - `min_value` _(number)_: 最小值
  - `max_value` _(number)_: 最大值

- **返回:**
  - `clamped_value` _(number)_: 限制后的值

### distance

---

```lua
helper.distance(pos1, pos2)
```

计算两点之间的距离。

- **参数:**
  - `pos1` _(vector3)_: 第一个位置
  - `pos2` _(vector3)_: 第二个位置

- **返回:**
  - `distance` _(number)_: 两点之间的距离

### sign

---

```lua
helper.sign(x)
```

符号函数。返回数字的符号。

- **参数:**
  - `x` _(number)_: 输入值

- **返回:**
  - `sign` _(number)_: 符号值（-1, 0, 或 1）

### round

---

```lua
helper.round(x)
```

四舍五入函数。

- **参数:**
  - `x` _(number)_: 要四舍五入的值

- **返回:**
  - `rounded` _(number)_: 四舍五入后的值

### lerp

---

```lua
helper.lerp(t, v1, v2)
```

线性插值函数。

- **参数:**
  - `t` _(number)_: 插值因子（0 到 1）
  - `v1` _(number|vector3|vector4)_: 起始值
  - `v2` _(number|vector3|vector4)_: 结束值

- **返回:**
  - `interpolated_value` _(number|vector3|vector4)_: 插值结果

### contains

---

```lua
helper.contains(array, value)
```

检查数组是否包含指定值。

- **参数:**
  - `array` _(table)_: 要搜索的数组
  - `value` _(any)_: 要查找的值

- **返回:**
  - `found` _(boolean)_: 是否找到值

### deepcopy

---

```lua
helper.deepcopy(orig)
```

深度复制表。

- **参数:**
  - `orig` _(table)_: 要复制的原始表

- **返回:**
  - `copy` _(table)_: 复制的表

### add_array

---

```lua
helper.add_array(target, source)
```

将源数组的所有元素添加到目标数组。

- **参数:**
  - `target` _(table)_: 目标数组
  - `source` _(table)_: 源数组

- **返回:**
  - `target` _(table)_: 修改后的目标数组

### pick_node

---

```lua
helper.pick_node(x, y, node)
```

检测点是否在节点内。

- **参数:**
  - `x` _(number)_: X 坐标
  - `y` _(number)_: Y 坐标
  - `node` _(node)_: 要检测的节点

- **返回:**
  - `picked` _(boolean)_: 是否在节点内

### get_scaled_size

---

```lua
helper.get_scaled_size(node)
```

获取缩放后的节点大小。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `size` _(vector3)_: 缩放后的大小

### get_scene_scale

---

```lua
helper.get_scene_scale()
```

获取场景缩放比例。

- **返回:**
  - `scale` _(vector3)_: 场景缩放向量

### get_closest_stencil_node

---

```lua
helper.get_closest_stencil_node(node)
```

获取最接近的模板节点。

- **参数:**
  - `node` _(node)_: 参考节点

- **返回:**
  - `stencil_node` _(node)_: 最近的模板节点

### get_pivot_offset

---

```lua
helper.get_pivot_offset(node)
```

获取节点枢轴偏移。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `offset` _(vector3)_: 枢轴偏移量

### is_desktop

---

```lua
helper.is_desktop()
```

检查是否在桌面平台上运行。

- **返回:**
  - `is_desktop` _(boolean)_: 是否为桌面平台

### is_mobile

---

```lua
helper.is_mobile()
```

检查是否在移动平台上运行。

- **返回:**
  - `is_mobile` _(boolean)_: 是否为移动平台

### is_web

---

```lua
helper.is_web()
```

检查是否在网页平台上运行。

- **返回:**
  - `is_web` _(boolean)_: 是否为网页平台

### is_web_mobile

---

```lua
helper.is_web_mobile()
```

检查是否在网页移动端平台上运行。

- **返回:**
  - `is_web_mobile` _(boolean)_: 是否为网页移动端平台

### is_multitouch_supported

---

```lua
helper.is_multitouch_supported()
```

检查是否支持多点触控。

- **返回:**
  - `supported` _(boolean)_: 是否支持多点触控

### table_to_string

---

```lua
helper.table_to_string(table)
```

将表转换为字符串表示。

- **参数:**
  - `table` _(table)_: 要转换的表

- **返回:**
  - `string` _(string)_: 表的字符串表示

### get_border

---

```lua
helper.get_border(node)
```

获取节点的边界。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `border` _(table)_: 包含 left, right, top, bottom 的边界表

### get_text_metrics_from_node

---

```lua
helper.get_text_metrics_from_node(node)
```

从文本节点获取文本度量信息。

- **参数:**
  - `node` _(node)_: 文本节点

- **返回:**
  - `metrics` _(table)_: 包含文本度量信息的表

### insert_with_shift

---

```lua
helper.insert_with_shift(array, index, value)
```

插入元素并移动后续元素。

- **参数:**
  - `array` _(table)_: 数组
  - `index` _(number)_: 插入索引
  - `value` _(any)_: 要插入的值

### remove_with_shift

---

```lua
helper.remove_with_shift(array, index)
```

删除元素并移动后续元素。

- **参数:**
  - `array` _(table)_: 数组
  - `index` _(number)_: 要删除的索引

- **返回:**
  - `removed_value` _(any)_: 删除的值

### get_full_position

---

```lua
helper.get_full_position(node)
```

获取节点的完整位置（考虑父节点变换）。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `position` _(vector3)_: 完整的位置向量

### get_animation_data_from_node

---

```lua
helper.get_animation_data_from_node(node)
```

从节点获取动画数据。

- **参数:**
  - `node` _(node)_: 节点

- **返回:**
  - `animation_data` _(table)_: 动画数据表
