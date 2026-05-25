# druid.lang_text API

> 位于 /druid/extended/lang_text.lua

用于显示本地化文本的组件，可以在区域设置更改时自动更新文本。
它包装了 Text 组件，使用 druid 的 get_text_function 通过 ID 设置文本以处理本地化。

### 设置

使用 druid 创建多语言文本组件：`text = druid:new_lang_text(node_name, locale_id)`

### 注意事项

- 区域设置更改时，组件会自动更新文本
- 使用 druid 的 get_text_function 通过 ID 获取本地化文本
- 支持使用附加参数进行字符串格式化

## 函数

- [init](#init)
- [set_to](#set_to)
- [set_text](#set_text)
- [translate](#translate)
- [format](#format)

## 字段

- [text](#text)
- [node](#node)
- [on_change](#on_change)
- [druid](#druid)

### init

---

```lua
lang_text:init(node, [locale_id], [adjust_type])
```

- **参数:**
  - `node` _(string|node)_: 节点 ID 或 gui.get_node(node_id)
  - `[locale_id]` _(string|nil)_: 默认区域 ID 或来自节点的文本作为默认值。如果未提供，将使用来自节点的文本
  - `[adjust_type]` _(string|nil)_: 文本调整类型。默认为 DOWNSCALE。参考 const.TEXT_ADJUST

- **返回:**
  - `` _(druid.lang_text)_:

### set_to

---

```lua
lang_text:set_to(locale_id)
```

设置本地化文本 ID。

- **参数:**
  - `locale_id` _(string)_: 本地化文本 ID

### set_text

---

```lua
lang_text:set_text(text_value)
```

设置文本内容。

- **参数:**
  - `text_value` _(string)_: 文本值

### translate

---

```lua
lang_text:translate(locale_id, [args])
```

翻译并设置文本。

- **参数:**
  - `locale_id` _(string)_: 本地化 ID
  - `[args]` _(table)_: 格式化参数

### format

---

```lua
lang_text:format(text, [args])
```

格式化文本。

- **参数:**
  - `text` _(string)_: 要格式化的文本
  - `[args]` _(table)_: 格式化参数

## 事件字段

### text

文本组件实例。

### node

多语言文本组件关联的节点。

### on_change

文本更改时的回调函数。

### druid

关联的 Druid 实例。
