# druid.blocker API

> 位于 /druid/base/blocker.lua

用于阻止输入的 Druid 组件。用于在特定区域阻止输入。

### 设置

使用 druid 创建阻挡器组件：`druid:new_blocker(node_name)`

### 注意事项

- 阻挡器可用于创建安全区域，在这些区域中有大的按钮
- 阻挡器将捕获命中节点的所有输入事件，防止它们到达其他组件
- 阻挡器作为常规组件放置在堆栈中，因此任何其他组件都可以放置在其顶部并照常工作

## 函数

- [init](#init)
- [set_enabled](#set_enabled)
- [is_enabled](#is_enabled)

## 字段

- [node](#node)

### init

---

```lua
blocker:init(node)
```

阻挡器构造函数。

- **参数:**
  - `node` _(string|node)_: 用作阻挡器的节点

### set_enabled

---

```lua
blocker:set_enabled(state)
```

设置阻挡器启用状态。

- **参数:**
  - `state` _(boolean)_: 新的启用状态

### is_enabled

---

```lua
blocker:is_enabled()
```

检查阻挡器是否启用。

- **返回:**
  - `enabled` _(boolean)_: 是否启用

## 事件字段

### node

阻挡器组件关联的节点。
