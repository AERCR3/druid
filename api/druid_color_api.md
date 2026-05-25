# druid.color API

> 位于 /druid/color.lua

用于处理颜色的颜色面板和实用函数。
支持面板管理、十六进制转换、RGB/HSB 转换和颜色插值。

## 函数

- [get_color](#get_color)
- [add_palette](#add_palette)
- [get_palette](#get_palette)
- [set_color](#set_color)
- [lerp](#lerp)
- [hex2rgb](#hex2rgb)
- [hex2vector4](#hex2vector4)
- [rgb2hsb](#rgb2hsb)
- [hsb2rgb](#hsb2rgb)
- [rgb2hex](#rgb2hex)

### get_color

---

```lua
color.get_color(color_id)
```

根据 ID 从面板获取颜色，十六进制字符串，或直接返回向量。
如果在面板中找不到 color_id 并且不是十六进制字符串，则返回白色。

- **参数:**
  - `color_id` _(string|vector3|vector4)_: 来自面板的颜色 ID，十六进制颜色字符串，或向量

- **返回:**
  - `` _(vector4)_:

### add_palette

---

```lua
color.add_palette(palette_data)
```

向面板添加颜色。颜色可以是十六进制字符串或 vector4 值。

- **参数:**
  - `palette_data` _(table<string, string|vector4>)_: 以颜色 ID 为键的表

### get_palette

---

```lua
color.get_palette()
```

获取所有面板颜色。

- **返回:**
  - `` _(table<string, vector4>)_:

### set_color

---

```lua
color.set_color(gui_node, color)
```

设置 GUI 节点颜色。不改变透明度。

- **参数:**
  - `gui_node` _(node)_:
  - `color` _(string|vector3|vector4)_:

### lerp

---

```lua
color.lerp(t, color1, color2)
```

在两种颜色之间进行插值，使用 HSB 空间（比 RGB 更好的视觉效果）。

- **参数:**
  - `t` _(number)_: 插值数值 (0 = color1, 1 = color2)
  - `color1` _(vector4)_:
  - `color2` _(vector4)_:

- **返回:**
  - `` _(vector4)_:

### hex2rgb

---

```lua
color.hex2rgb(hex)
```

将十六进制字符串转换为 RGB 值（0-1 范围）。支持 #RGB 和 #RRGGBB 格式。

- **参数:**
  - `hex` _(string)_: 十六进制颜色字符串

- **返回:**
  - `rgb` _(vector3)_: RGB 向量（范围 0-1）

### hex2vector4

---

```lua
color.hex2vector4(hex)
```

将十六进制字符串转换为 vector4 颜色。

- **参数:**
  - `hex` _(string)_: 十六进制颜色字符串

- **返回:**
  - `color` _(vector4)_: RGBA 向量（范围 0-1）

### rgb2hsb

---

```lua
color.rgb2hsb(rgb)
```

将 RGB 颜色转换为 HSB 颜色空间。

- **参数:**
  - `rgb` _(vector3)_: RGB 颜色向量（范围 0-1）

- **返回:**
  - `hsb` _(vector3)_: HSB 颜色向量

### hsb2rgb

---

```lua
color.hsb2rgb(hsb)
```

将 HSB 颜色转换为 RGB 颜色空间。

- **参数:**
  - `hsb` _(vector3)_: HSB 颜色向量

- **返回:**
  - `rgb` _(vector3)_: RGB 颜色向量（范围 0-1）

### rgb2hex

---

```lua
color.rgb2hex(rgb)
```

将 RGB 颜色转换为十六进制字符串。

- **参数:**
  - `rgb` _(vector3)_: RGB 颜色向量（范围 0-1）

- **返回:**
  - `hex` _(string)_: 十六进制颜色字符串
