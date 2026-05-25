# druid.instance API

> 位于 /druid/system/druid_instance.lua

用于创建组件的 Druid 工厂

## 函数

- [create_druid_instance](#create_druid_instance)
- [new](#new)
- [final](#final)
- [remove](#remove)
- [update](#update)
- [on_input](#on_input)
- [on_message](#on_message)
- [on_window_event](#on_window_event)
- [set_whitelist](#set_whitelist)
- [set_blacklist](#set_blacklist)
- [new_widget](#new_widget)
- [new_button](#new_button)
- [new_blocker](#new_blocker)
- [new_back_handler](#new_back_handler)
- [new_hover](#new_hover)
- [new_text](#new_text)
- [new_grid](#new_grid)
- [new_scroll](#new_scroll)
- [new_drag](#new_drag)
- [new_swipe](#new_swipe)
- [new_lang_text](#new_lang_text)
- [new_slider](#new_slider)
- [new_input](#new_input)
- [new_data_list](#new_data_list)
- [new_timer](#new_timer)
- [new_progress](#new_progress)
- [new_layout](#new_layout)
- [new_container](#new_container)
- [new_hotkey](#new_hotkey)
- [new_rich_text](#new_rich_text)
- [new_rich_input](#new_rich_input)

### create_druid_instance

---

```lua
instance.create_druid_instance(context, [style])
```

用于创建 Druid 组件的 Druid 类构造函数

- **参数:**
  - `context` _(table)_: Druid 上下文。通常是 gui 脚本的 self
  - `[style]` _(table?)_: Druid 样式表

- **返回:**
  - `instance` _(druid.instance)_: 新的 Druid 实例

### new

---

```lua
instance:new(component, ...)
```

创建新的 Druid 组件实例

- **参数:**
  - `component` _(<T:druid.component>)_: 要创建的组件类
  - `...` _(...)_: 可变参数

- **返回:**
  - `instance` _(<T:druid.component>)_: 新的可使用的组件

### final

---

```lua
instance:final()
```

在 gui_script 的 final 函数中调用此方法。

### remove

---

```lua
instance:remove(component)
```

从 Druid 实例中移除已创建的组件。
如果存在，将调用组件的 `on_remove` 函数。

- **参数:**
  - `component` _(<T:druid.component>)_: 组件实例

- **返回:**
  - `is_removed` _(boolean)_: 如果组件被移除则为 True

### update

---

```lua
instance:update(dt)
```

更新所有组件。在 gui_script 的 update 函数中调用。

- **参数:**
  - `dt` _(number)_: 时间增量

### on_input

---

```lua
instance:on_input(action_id, action)
```

处理输入事件。在 gui_script 的 on_input 函数中调用。

- **参数:**
  - `action_id` _(hash)_: 动作 ID
  - `action` _(table)_: 动作表

- **返回:**
  - `consumed` _(boolean)_: 如果输入被消费则为 True

### on_message

---

```lua
instance:on_message(message_id, message, sender)
```

处理消息事件。在 gui_script 的 on_message 函数中调用。

- **参数:**
  - `message_id` _(hash)_: 消息 ID
  - `message` _(table)_: 消息内容
  - `sender` _(url)_: 发送者 URL

### on_window_event

---

```lua
instance:on_window_event(event)
```

处理窗口事件。在 gui_script 的 on_window_event 函数中调用。

- **参数:**
  - `event` _(string)_: 窗口事件

### set_whitelist

---

```lua
instance:set_whitelist(component_names)
```

设置组件白名单。只有白名单中的组件才能被创建。

- **参数:**
  - `component_names` _(table)_: 组件名称数组

### set_blacklist

---

```lua
instance:set_blacklist(component_names)
```

设置组件黑名单。黑名单中的组件不能被创建。

- **参数:**
  - `component_names` _(table)_: 组件名称数组

### new_widget

---

```lua
instance:new_widget(widget_class, ...)
```

创建新的小部件实例。

- **参数:**
  - `widget_class` _(table)_: 小部件类
  - `...` _(...)_: 传递给小部件构造函数的参数

- **返回:**
  - `widget` _(table)_: 小部件实例

### new_button

---

```lua
instance:new_button(node, callback, [params], [animation_node])
```

创建新的按钮组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `callback` _(function)_: 按钮回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数
  - `[animation_node]` _(node|string)_: 用于动画的节点

- **返回:**
  - `button` _(druid.button)_: 按钮组件实例

### new_blocker

---

```lua
instance:new_blocker()
```

创建新的阻挡器组件。

- **返回:**
  - `blocker` _(druid.blocker)_: 阻挡器组件实例

### new_back_handler

---

```lua
instance:new_back_handler(callback)
```

创建新的返回键处理器组件。

- **参数:**
  - `callback` _(function)_: 返回键回调函数

- **返回:**
  - `back_handler` _(druid.back_handler)_: 返回键处理器组件实例

### new_hover

---

```lua
instance:new_hover(node, [params])
```

创建新的悬停组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[params]` _(table)_: 悬停参数

- **返回:**
  - `hover` _(druid.hover)_: 悬停组件实例

### new_text

---

```lua
instance:new_text(node, [text])
```

创建新的文本组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[text]` _(string)_: 初始文本

- **返回:**
  - `text` _(druid.text)_: 文本组件实例

### new_grid

---

```lua
instance:new_grid(node, [params])
```

创建新的网格组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[params]` _(table)_: 网格参数

- **返回:**
  - `grid` _(druid.grid)_: 网格组件实例

### new_scroll

---

```lua
instance:new_scroll(scroll_node, content_node, [params])
```

创建新的滚动组件。

- **参数:**
  - `scroll_node` _(node|string)_: 滚动容器节点
  - `content_node` _(node|string)_: 内容节点
  - `[params]` _(table)_: 滚动参数

- **返回:**
  - `scroll` _(druid.scroll)_: 滚动组件实例

### new_drag

---

```lua
instance:new_drag(node, callback, [params])
```

创建新的拖拽组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `callback` _(function)_: 拖拽回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `drag` _(druid.drag)_: 拖拽组件实例

### new_swipe

---

```lua
instance:new_swipe(node, callback, [params])
```

创建新的滑动手势组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `callback` _(function)_: 滑动回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `swipe` _(druid.swipe)_: 滑动组件实例

### new_lang_text

---

```lua
instance:new_lang_text(node, text_id, [params])
```

创建新的多语言文本组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `text_id` _(string)_: 文本 ID
  - `[params]` _(table)_: 参数

- **返回:**
  - `lang_text` _(druid.lang_text)_: 多语言文本组件实例

### new_slider

---

```lua
instance:new_slider(track_node, thumb_node, callback, [params])
```

创建新的滑块组件。

- **参数:**
  - `track_node` _(node|string)_: 轨道节点
  - `thumb_node` _(node|string)_: 滑块节点
  - `callback` _(function)_: 滑块回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `slider` _(druid.slider)_: 滑块组件实例

### new_input

---

```lua
instance:new_input(node, callback, [params])
```

创建新的输入组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `callback` _(function)_: 输入回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `input` _(druid.input)_: 输入组件实例

### new_data_list

---

```lua
instance:new_data_list(node, item_template, [params])
```

创建新的数据列表组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `item_template` _(string)_: 项目模板名称
  - `[params]` _(table)_: 参数

- **返回:**
  - `data_list` _(druid.data_list)_: 数据列表组件实例

### new_timer

---

```lua
instance:new_timer(callback, [params])
```

创建新的计时器组件。

- **参数:**
  - `callback` _(function)_: 计时器回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `timer` _(druid.timer)_: 计时器组件实例

### new_progress

---

```lua
instance:new_progress(node, [params])
```

创建新的进度条组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[params]` _(table)_: 参数

- **返回:**
  - `progress` _(druid.progress)_: 进度条组件实例

### new_layout

---

```lua
instance:new_layout(node, [params])
```

创建新的布局组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[params]` _(table)_: 参数

- **返回:**
  - `layout` _(druid.layout)_: 布局组件实例

### new_container

---

```lua
instance:new_container(node, [params])
```

创建新的容器组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[params]` _(table)_: 参数

- **返回:**
  - `container` _(druid.container)_: 容器组件实例

### new_hotkey

---

```lua
instance:new_hotkey(key, callback, [params])
```

创建新的热键组件。

- **参数:**
  - `key` _(string)_: 热键
  - `callback` _(function)_: 热键回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `hotkey` _(druid.hotkey)_: 热键组件实例

### new_rich_text

---

```lua
instance:new_rich_text(node, [text])
```

创建新的富文本组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `[text]` _(string)_: 初始文本

- **返回:**
  - `rich_text` _(druid.rich_text)_: 富文本组件实例

### new_rich_input

---

```lua
instance:new_rich_input(node, callback, [params])
```

创建新的富输入组件。

- **参数:**
  - `node` _(node|string)_: GUI 节点或节点名称
  - `callback` _(function)_: 输入回调函数
  - `[params]` _(any)_: 传递给回调函数的额外参数

- **返回:**
  - `rich_input` _(druid.rich_input)_: 富输入组件实例
