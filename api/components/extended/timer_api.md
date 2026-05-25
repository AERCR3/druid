# druid.timer API

> 位于 /druid/extended/timer.lua

Druid 组件，用于处理 GUI 文本节点上的定时器工作。以格式化的方式显示时间。

### 设置

使用 druid 创建定时器组件：`timer = druid:new_timer(text_node, from_seconds, to_seconds, callback)`

### 注意事项

- 当定时器值等于 _to_seconds_ 时，定时器触发回调
- 定时器将用当前定时器值设置文本节点
- 定时器使用更新函数来处理时间

## 函数

- [init](#init)
- [set_to](#set_to)
- [set_state](#set_state)
- [set_interval](#set_interval)

## 字段

- [on_tick](#on_tick)
- [on_set_enabled](#on_set_enabled)
- [on_timer_end](#on_timer_end)
- [node](#node)
- [from](#from)
- [target](#target)
- [value](#value)
- [is_on](#is_on)
- [temp](#temp)
- [last_value](#last_value)

### init

---

```lua
timer:init(node, [seconds_from], [seconds_to], [callback])
```

- **参数:**
  - `node` _(node)_: GUI 文本节点
  - `[seconds_from]` _(number|nil)_: 开始定时器值（秒）
  - `[seconds_to]` _(number|nil)_: 结束定时器值（秒）
  - `[callback]` _(function|nil)_: 当定时器值等于 seconds_to 时触发的函数

- **返回:**
  - `` _(druid.timer)_:

### set_to

---

```lua
timer:set_to(from, to, [callback])
```

设置定时器的起始和结束值。

- **参数:**
  - `from` _(number)_: 起始值
  - `to` _(number)_: 结束值
  - `[callback]` _(function)_: 定时器结束时的回调函数

### set_state

---

```lua
timer:set_state(is_enabled)
```

设置定时器状态。

- **参数:**
  - `is_enabled` _(boolean)_: 是否启用定时器

### set_interval

---

```lua
timer:set_interval(interval)
```

设置定时器间隔。

- **参数:**
  - `interval` _(number)_: 定时器间隔

## 事件字段

### on_tick

定时器滴答时的回调函数。

### on_set_enabled

设置启用状态时的回调函数。

### on_timer_end

定时器结束时的回调函数。

### node

定时器组件关联的节点。

### from

定时器起始值。

### target

定时器目标值。

### value

当前定时器值。

### is_on

定时器是否正在运行。

### temp

临时存储值。

### last_value

上次定时器值。
