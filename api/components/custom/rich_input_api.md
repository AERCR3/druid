# druid.rich_input API

> 位于 /druid/custom/rich_input/rich_input.lua

处理富文本输入字段的组件，它是 druid.input 组件的包装器

## 函数

- [init](#init)
- [set_placeholder](#set_placeholder)
- [select](#select)
- [set_text](#set_text)
- [set_font](#set_font)
- [get_text](#get_text)
- [set_allowed_characters](#set_allowed_characters)

## 字段

- [root](#root)
- [input](#input)
- [cursor](#cursor)
- [cursor_text](#cursor_text)
- [cursor_position](#cursor_position)
- [druid](#druid)
- [is_lshift](#is_lshift)
- [is_lctrl](#is_lctrl)
- [is_button_input_enabled](#is_button_input_enabled)
- [drag](#drag)
- [placeholder](#placeholder)
- [text_position](#text_position)

### init

---

```lua
rich_input:init(template, nodes)
```

- **参数:**
  - `template` _(string)_: 模板字符串名称
  - `nodes` _(table)_: 来自 gui.clone_tree 的节点表

### set_placeholder

---

```lua
rich_input:set_placeholder(placeholder_text)
```

设置占位符文本。

- **参数:**
  - `placeholder_text` _(string)_: 占位符文本

### select

---

```lua
rich_input:select()
```

选择输入字段。

### set_text

---

```lua
rich_input:set_text(text)
```

设置输入文本。

- **参数:**
  - `text` _(string)_: 要设置的文本

### set_font

---

```lua
rich_input:set_font(font)
```

设置字体。

- **参数:**
  - `font` _(string|resource)_: 字体资源

### get_text

---

```lua
rich_input:get_text()
```

获取输入文本。

- **返回:**
  - `text` _(string)_: 当前输入文本

### set_allowed_characters

---

```lua
rich_input:set_allowed_characters(allowed_chars)
```

设置允许的字符。

- **参数:**
  - `allowed_chars` _(string)_: 允许的字符

## 事件字段

### root

根节点。

### input

输入组件实例。

### cursor

光标节点。

### cursor_text

光标文本。

### cursor_position

光标位置。

### druid

关联的 Druid 实例。

### is_lshift

是否按下左 Shift 键。

### is_lctrl

是否按下左 Ctrl 键。

### is_button_input_enabled

按钮输入是否启用。

### drag

拖动组件引用。

### placeholder

占位符文本。

### text_position

文本位置。
