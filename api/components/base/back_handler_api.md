# druid.back_handler API

> 位于 /druid/base/back_handler.lua

用于处理返回按钮的组件。它处理 Android 返回按钮和退格键。

### 设置

使用 druid 创建返回处理器组件：`druid:new_back_handler(callback)`

### 注意事项

- 应为 `input.binding` 设置键触发器以正确工作
- 它使用 key_back 和 key_backspace 动作 ID

## 函数

- [init](#init)

## 字段

- [on_back](#on_back)
- [params](#params)

### init

---

```lua
back_handler:init([callback], [params])
```

返回处理器构造函数。

- **参数:**
  - `[callback]` _(function|nil)_: 当返回处理器被触发时调用的回调函数
  - `[params]` _(any)_: 传递给回调函数的自定义参数

## 事件字段

### on_back

返回处理器动作触发时的回调函数。
函数签名：fun(self: druid.back_handler, params: any?)

### params

传递给回调函数的自定义参数。
