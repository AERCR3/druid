# druid.input API

> 位于 /druid/extended/input.lua

基本的 Druid 文本输入组件。通过带有按钮和文本的组件处理用户文本输入。

### 设置

使用 druid 创建输入组件：`input = druid:new_input(button_node_name, text_node_name, keyboard_type)`

### 注意事项

- 输入组件处理用户文本输入。输入包含按钮和文本组件
- 按钮用于选择/取消选择输入字段
- 点击按钮外部以取消选择输入字段
- 焦点丢失（游戏最小化）时，输入字段将被取消选择
- 您可以设置文本的最大长度
- 您可以设置允许的字符。添加不允许的字符时将调用 `on_input_wrong`

## 函数

- [init](#init)
- [get_text_selected](#get_text_selected)
- [get_text_selected_replaced](#get_text_selected_replaced)
- [set_text](#set_text)
- [select](#select)
- [unselect](#unselect)
- [get_text](#get_text)
- [set_max_length](#set_max_length)
- [set_allowed_characters](#set_allowed_characters)
- [reset_changes](#reset_changes)
- [select_cursor](#select_cursor)
- [move_selection](#move_selection)

## 字段

- [on_input_select](#on_input_select)
- [on_input_unselect](#on_input_unselect)
- [on_input_text](#on_input_text)
- [on_input_empty](#on_input_empty)
- [on_input_full](#on_input_full)
- [on_input_wrong](#on_input_wrong)
- [on_select_cursor_change](#on_select_cursor_change)
- [style](#style)
- [druid](#druid)
- [text](#text)
- [is_selected](#is_selected)
- [value](#value)
- [previous_value](#previous_value)
- [current_value](#current_value)
- [marked_value](#marked_value)
- [is_empty](#is_empty)
- [text_width](#text_width)

### init

---

```lua
input:init(click_node, text_node, [params])
```

输入组件初始化。

- **参数:**
  - `click_node` _(node)_: 点击节点
  - `text_node` _(node)_: 文本节点
  - `[params]` _(table)_: 输入参数

### get_text_selected

---

```lua
input:get_text_selected()
```

获取选中的文本。

- **返回:**
  - `selected_text` _(string)_: 选中的文本

### get_text_selected_replaced

---

```lua
input:get_text_selected_replaced(new_text)
```

获取替换选中文本后的新文本。

- **参数:**
  - `new_text` _(string)_: 新文本

- **返回:**
  - `result_text` _(string)_: 替换后的文本

### set_text

---

```lua
input:set_text(text)
```

设置输入文本。

- **参数:**
  - `text` _(string)_: 要设置的文本

### select

---

```lua
input:select()
```

选择输入字段。

### unselect

---

```lua
input:unselect()
```

取消选择输入字段。

### get_text

---

```lua
input:get_text()
```

获取输入文本。

- **返回:**
  - `text` _(string)_: 当前输入文本

### set_max_length

---

```lua
input:set_max_length(max_length)
```

设置最大长度。

- **参数:**
  - `max_length` _(number)_: 最大长度

### set_allowed_characters

---

```lua
input:set_allowed_characters(allowed_chars)
```

设置允许的字符。

- **参数:**
  - `allowed_chars` _(string)_: 允许的字符

### reset_changes

---

```lua
input:reset_changes()
```

重置更改。

### select_cursor

---

```lua
input:select_cursor(cursor_pos, [length])
```

选择光标位置。

- **参数:**
  - `cursor_pos` _(number)_: 光标位置
  - `[length]` _(number)_: 选择长度

### move_selection

---

```lua
input:move_selection(offset)
```

移动选择。

- **参数:**
  - `offset` _(number)_: 偏移量

## 事件字段

### on_input_select

输入选择时的回调函数。

### on_input_unselect

输入取消选择时的回调函数。

### on_input_text

输入文本时的回调函数。

### on_input_empty

输入为空时的回调函数。

### on_input_full

输入满时的回调函数。

### on_input_wrong

输入错误字符时的回调函数。

### on_select_cursor_change

选择光标更改时的回调函数。

### style

输入组件样式配置。

### druid

关联的 Druid 实例。

### text

文本组件实例。

### is_selected

输入字段是否被选中。

### value

当前输入值。

### previous_value

之前的输入值。

### current_value

当前输入值。

### marked_value

标记的值。

### is_empty

输入是否为空。

### text_width

文本宽度。
