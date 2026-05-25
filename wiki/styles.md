# 样式

## 概述

样式 - 用于自定义组件行为的一组函数和参数。

样式是一个表，其中键是组件的名称，值是此组件的样式表。

在组件API文档中，您可以找到此组件的样式API。或者只需查找现有样式并修改它们。

## 用法

通过 `druid.set_default_style` 为所有druid实例设置默认druid样式
您可以传递 _nil_ 或 _empty_table_ 以使用所有组件的默认值（无样式）

```lua
local druid = require("druid.druid")
local my_style = require("my.amazing.style")

function init(self)
    druid.set_default_style(my_style)
end
```

为特定的druid实例设置自定义样式：

```lua
local druid = require("druid.druid")
local my_style = require("my.amazing.style")

function init(self)
    -- 此druid实例将使用my_style作为默认样式
    self.druid = druid.new(self, my_style)
end
```

使用 _set_style_ 函数更改组件样式

```lua
local druid = require("druid.druid")
local my_style = require("my.amazing.style")

function init(self)
	self.druid = druid.new(self)
	self.button = self.druid:new_button("node", function() end)
	-- 为特定组件设置自定义样式
	self.button:set_style(my_style)
end
```

## 就地调整样式

您可以在组件创建后立即调整样式参数。

```lua
local druid = require("druid.druid")

function init(self)
	self.druid = druid.new(self)
	self.grid = self.druid:new_grid("node", "prefab", 1)
	self.grid.style.IS_ALIGN_LAST_ROW = true

	self.drag = self.druid:new_drag("node")
	self.drag.style.DRAG_DEADZONE = 0
end
```


## 创建您自己的样式

大多数组件都有其样式。您可以在 [Druid API](https://insality.github.io/druid/) 的表格样式部分中探索它（[按钮示例](https://insality.github.io/druid/modules/Button.html#style)）。或者您可以看到组件在 `on_style_change` 函数中的代码使用了哪些字段

要创建您的样式，请创建一个返回 <_component_name_, _component_style_> 表的lua模块

示例：[默认druid样式](https://github.com/Insality/druid/blob/master/druid/styles/default/style.lua)

覆盖所有您想要的字段，并通过以下方式之一设置您的样式：

- 通过 `druid.set_default_style` 将您的样式设置为全局样式
- 通过 `druid = druid.new(self, style)` 为具体的druid实例设置样式
- 通过 `component:set_style(style)` 为具体实例设置样式