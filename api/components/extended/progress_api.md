# druid.progress API

> 位于 /druid/extended/progress.lua

基本的 Druid 进度条组件。通过更改节点的大小或比例来表示进度。

### 设置

使用 druid 创建进度条组件：`progress = druid:new_progress(node_name, key, init_value)`

### 注意事项

- 节点在 GUI 场景中应具有最大节点大小，它代表进度条的最大大小
- 键是来自 druid 常量的值："x" 或 "y"
- 进度条与 9切片节点正确工作，它首先尝试通过 _set_size_ 设置大小直到达到最小大小，然后通过 _set_scale_ 继续调整大小
- 进度条只能按垂直或水平大小填充。对于对角线进度条，只需在 GUI 场景中旋转节点
- 如果进度条出现闪烁或纹理错误，请尝试在纹理配置文件中禁用 Mipmap

## 函数

- [init](#init)
- [update](#update)
- [fill](#fill)
- [empty](#empty)
- [set_to](#set_to)
- [get](#get)
- [set_steps](#set_steps)
- [to](#to)
- [set_max_size](#set_max_size)

## 字段

- [node](#node)
- [on_change](#on_change)
- [style](#style)
- [key](#key)
- [prop](#prop)
- [scale](#scale)
- [size](#size)
- [max_size](#max_size)
- [slice](#slice)
- [last_value](#last_value)
- [slice_size](#slice_size)
- [target](#target)
- [steps](#steps)
- [step_callback](#step_callback)
- [target_callback](#target_callback)

### init

---

```lua
progress:init(node, key, [init_value])
```

进度条组件初始化。

- **参数:**
  - `node` _(node)_: GUI 节点
  - `key` _(string)_: 方向键 ("x" 或 "y")
  - `[init_value]` _(number)_: 初始值（0-1）

### update

---

```lua
progress:update(dt)
```

更新进度条。

- **参数:**
  - `dt` _(number)_: 时间增量

### fill

---

```lua
progress:fill([duration])
```

填充进度条。

- **参数:**
  - `[duration]` _(number)_: 填充持续时间

### empty

---

```lua
progress:empty([duration])
```

清空进度条。

- **参数:**
  - `[duration]` _(number)_: 清空持续时间

### set_to

---

```lua
progress:set_to(value, [duration])
```

设置进度条值。

- **参数:**
  - `value` _(number)_: 进度值（0-1）
  - `[duration]` _(number)_: 设置持续时间

### get

---

```lua
progress:get()
```

获取当前进度值。

- **返回:**
  - `value` _(number)_: 当前进度值（0-1）

### set_steps

---

```lua
progress:set_steps(steps, [callback])
```

设置进度步进。

- **参数:**
  - `steps` _(table)_: 步进值数组
  - `[callback]` _(function)_: 步进回调函数

### to

---

```lua
progress:to(value, [duration], [callback])
```

设置进度到指定值。

- **参数:**
  - `value` _(number)_: 目标值（0-1）
  - `[duration]` _(number)_: 持续时间
  - `[callback]` _(function)_: 完成回调函数

### set_max_size

---

```lua
progress:set_max_size(max_size)
```

设置最大大小。

- **参数:**
  - `max_size` _(vector3)_: 最大大小

## 事件字段

### node

进度条组件关联的节点。

### on_change

进度更改时的回调函数。

### style

进度条组件样式配置。

### key

方向键 ("x" 或 "y")。

### prop

属性名称。

### scale

当前比例。

### size

当前大小。

### max_size

最大大小。

### slice

切片信息。

### last_value

上次进度值。

### slice_size

切片大小。

### target

目标值。

### steps

步进值数组。

### step_callback

步进回调函数。

### target_callback

目标回调函数。
