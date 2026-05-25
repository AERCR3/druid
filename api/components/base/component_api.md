# druid.component API

> 位于 /druid/component.lua

## 函数

- [create](#create)
- [create_widget](#create_widget)
- [init](#init)
- [update](#update)
- [on_remove](#on_remove)
- [on_input](#on_input)
- [on_input_interrupt](#on_input_interrupt)
- [on_message](#on_message)
- [on_late_init](#on_late_init)
- [on_focus_lost](#on_focus_lost)
- [on_focus_gained](#on_focus_gained)
- [on_style_change](#on_style_change)
- [on_layout_change](#on_layout_change)
- [on_window_resized](#on_window_resized)
- [on_language_change](#on_language_change)
- [set_style](#set_style)
- [set_template](#set_template)
- [get_template](#get_template)
- [set_nodes](#set_nodes)
- [get_context](#get_context)
- [get_node](#get_node)
- [get_druid](#get_druid)
- [get_name](#get_name)
- [get_parent_name](#get_parent_name)
- [get_input_priority](#get_input_priority)
- [set_input_priority](#set_input_priority)
- [reset_input_priority](#reset_input_priority)
- [get_uid](#get_uid)
- [set_input_enabled](#set_input_enabled)
- [get_input_enabled](#get_input_enabled)
- [get_parent_component](#get_parent_component)
- [get_nodes](#get_nodes)
- [get_childrens](#get_childrens)

## 字段

- [druid](#druid)

### create

---

```lua
component.create(base_type, meta)
```

创建新组件类型的工厂函数。

- **参数:**
  - `base_type` _(table)_: 基础组件类型
  - `meta` _(table)_: 组件元数据

- **返回:**
  - `component_type` _(table)_: 新的组件类型

### create_widget

---

```lua
component.create_widget(meta)
```

创建新组件类型的工厂函数。

- **参数:**
  - `meta` _(table)_: 组件元数据

- **返回:**
  - `component_type` _(table)_: 新的组件类型

### init

---

```lua
component.init(self, druid, name, ...)
```

组件初始化。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `druid` _(druid.instance)_: Druid 实例
  - `name` _(string)_: 组件名称
  - `...` _(...)_: 其他参数

### update

---

```lua
component.update(self, dt)
```

组件更新函数。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `dt` _(number)_: 时间增量

### on_remove

---

```lua
component.on_remove(self)
```

组件移除时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_input

---

```lua
component.on_input(self, action_id, action)
```

处理输入事件。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `action_id` _(hash)_: 动作 ID
  - `action` _(table)_: 动作表

- **返回:**
  - `consumed` _(boolean)_: 是否消费了输入事件

### on_input_interrupt

---

```lua
component.on_input_interrupt(self)
```

输入中断时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_message

---

```lua
component.on_message(self, message_id, message, sender)
```

处理消息事件。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `message_id` _(hash)_: 消息 ID
  - `message` _(table)_: 消息内容
  - `sender` _(url)_: 发送者 URL

### on_late_init

---

```lua
component.on_late_init(self)
```

延迟初始化。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_focus_lost

---

```lua
component.on_focus_lost(self)
```

失去焦点时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_focus_gained

---

```lua
component.on_focus_gained(self)
```

获得焦点时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_style_change

---

```lua
component.on_style_change(self)
```

样式更改时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_layout_change

---

```lua
component.on_layout_change(self)
```

布局更改时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### on_window_resized

---

```lua
component.on_window_resized(self, width, height)
```

窗口调整大小时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `width` _(number)_: 新宽度
  - `height` _(number)_: 新高度

### on_language_change

---

```lua
component.on_language_change(self)
```

语言更改时调用。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### set_style

---

```lua
component.set_style(self, style)
```

设置组件样式。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `style` _(table)_: 样式表

### set_template

---

```lua
component.set_template(self, template)
```

设置组件模板。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `template` _(table)_: 模板表

### get_template

---

```lua
component.get_template(self)
```

获取组件模板。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `template` _(table)_: 模板表

### set_nodes

---

```lua
component.set_nodes(self, nodes)
```

设置组件节点。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `nodes` _(table)_: 节点表

### get_context

---

```lua
component.get_context(self)
```

获取组件上下文。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `context` _(table)_: 组件上下文

### get_node

---

```lua
component.get_node(self, node_id)
```

获取节点。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `node_id` _(string)_: 节点 ID

- **返回:**
  - `node` _(node)_: GUI 节点

### get_druid

---

```lua
component.get_druid(self)
```

获取 Druid 实例。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `druid` _(druid.instance)_: Druid 实例

### get_name

---

```lua
component.get_name(self)
```

获取组件名称。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `name` _(string)_: 组件名称

### get_parent_name

---

```lua
component.get_parent_name(self)
```

获取父组件名称。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `parent_name` _(string)_: 父组件名称

### get_input_priority

---

```lua
component.get_input_priority(self)
```

获取输入优先级。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `priority` _(number)_: 输入优先级

### set_input_priority

---

```lua
component.set_input_priority(self, priority)
```

设置输入优先级。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `priority` _(number)_: 输入优先级

### reset_input_priority

---

```lua
component.reset_input_priority(self)
```

重置输入优先级。

- **参数:**
  - `self` _(druid.component)_: 组件实例

### get_uid

---

```lua
component.get_uid(self)
```

获取组件唯一 ID。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `uid` _(number)_: 唯一 ID

### set_input_enabled

---

```lua
component.set_input_enabled(self, enabled)
```

设置输入启用状态。

- **参数:**
  - `self` _(druid.component)_: 组件实例
  - `enabled` _(boolean)_: 是否启用输入

### get_input_enabled

---

```lua
component.get_input_enabled(self)
```

获取输入启用状态。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `enabled` _(boolean)_: 是否启用输入

### get_parent_component

---

```lua
component.get_parent_component(self)
```

获取父组件。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `parent` _(druid.component)_: 父组件

### get_nodes

---

```lua
component.get_nodes(self)
```

获取组件节点。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `nodes` _(table)_: 节点表

### get_childrens

---

```lua
component.get_childrens(self)
```

获取子组件。

- **参数:**
  - `self` _(druid.component)_: 组件实例

- **返回:**
  - `childrens` _(table)_: 子组件表

## 事件字段

### druid

组件关联的 Druid 实例。
