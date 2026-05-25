# druid.rich_text API

> 位于 /druid/custom/rich_text/rich_text.lua

处理富文本显示的组件，允许自定义文本部分的颜色、大小、字体等

## 函数

- [init](#init)
- [set_text](#set_text)
- [get_text](#get_text)
- [set_pivot](#set_pivot)
- [clear](#clear)
- [tagged](#tagged)
- [set_split_to_characters](#set_split_to_characters)
- [get_words](#get_words)
- [get_line_metric](#get_line_metric)
- [set_width](#set_width)
- [set_height](#set_height)

## 字段

- [root](#root)
- [text_prefab](#text_prefab)
- [style](#style)

### init

---

```lua
rich_text:init(text_node, [value])
```

- **参数:**
  - `text_node` _(string|node)_: 用于制作富文本的文本节点
  - `[value]` _(string|nil)_: 初始文本值。默认将是 gui.get_text(text_node)

### set_text

---

```lua
rich_text:set_text([text])
```

为富文本设置文本

- **参数:**
  - `[text]` _(string|nil)_: 要设置的文本

### get_text

---

```lua
rich_text:get_text()
```

获取富文本内容。

- **返回:**
  - `text` _(string)_: 当前文本内容

### set_pivot

---

```lua
rich_text:set_pivot(pivot)
```

设置富文本支点。

- **参数:**
  - `pivot` _(string)_: 支点类型

### clear

---

```lua
rich_text:clear()
```

清除富文本内容。

### tagged

---

```lua
rich_text:tagged(tag, text)
```

创建带标签的文本。

- **参数:**
  - `tag` _(string)_: 标签类型
  - `text` _(string)_: 文本内容

### set_split_to_characters

---

```lua
rich_text:set_split_to_characters(split)
```

设置是否拆分为字符。

- **参数:**
  - `split` _(boolean)_: 是否拆分为字符

### get_words

---

```lua
rich_text:get_words()
```

获取单词列表。

- **返回:**
  - `words` _(table)_: 单词列表

### get_line_metric

---

```lua
rich_text:get_line_metric()
```

获取行度量信息。

- **返回:**
  - `metrics` _(table)_: 行度量信息

### set_width

---

```lua
rich_text:set_width(width)
```

设置富文本宽度。

- **参数:**
  - `width` _(number)_: 宽度值

### set_height

---

```lua
rich_text:set_height(height)
```

设置富文本高度。

- **参数:**
  - `height` _(number)_: 高度值

## 事件字段

### root

根节点。

### text_prefab

文本预制件。

### style

富文本样式配置。
