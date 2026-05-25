# 创建自定义组件

# 已弃用

1.1版本中的自定义组件已被弃用。现在我们有了创建自定义组件的新方法 - 小部件。

自定义组件将继续存在于基础组件等系统性事物中。您不必迁移到小部件。

创建自定义组件的编辑器脚本已被移除。现在您可以使用新的编辑器脚本创建小部件。

在 [widgets.md](widgets.md) 中阅读更多关于小部件的信息

## 概述

Druid 提供了创建包含您自己逻辑的自定义组件的灵活性，以及其他 Druid 基础组件或自定义组件。虽然 Druid 提供了一组预定义的组件，如按钮和滚动条，但它超越了这一点，提供了一种更抽象的方式来处理所有 GUI 元素。自定义组件是分离逻辑并在代码中创建更高级别抽象的强大方法。

每个组件都是基础 Druid 组件的子类。您可以使用 `self:{method_name}` 调用基础组件的方法。

## 自定义组件

### 基础组件模板

基础自定义组件模板如下所示（您可以从 `/druid/templates/component.lua.template` 复制）：

```lua
local component = require("druid.component")

---@class component_name: druid.base_component
local M = component.create("component_name")

function M:init(template, nodes)
    self.druid = self:get_druid(template, nodes)
    self.root = self:get_node("root")

    self.button = self.druid:new_button("button", function() end)
end

function M:hello()
    print("来自自定义组件的问候")
end

return M
```

然后您可以使用 Druid 创建您的自定义组件：

```lua
local druid = require("druid.druid")

local my_component = require("my.amazing.component")

function init(self)
    self.druid = druid.new(self)

    -- 我们传递一个GUI模板"template_name"并跳过节点，因为它已经在场景中
    self.my_component = self.druid:new(my_component, "template_name")
    self.my_component:hello() -- 来自自定义组件的问候
end

```

### 完整组件模板

完整自定义组件模板如下所示（您可以从 `/druid/templates/component_full.lua.template` 复制）：

```lua
local component =  require("druid.component")

---@class component_name: druid.base_component
local M = component.create("component_name")

function M:init(template, nodes)
    self.druid = self:get_druid(template, nodes)
    self.root = self:get_node("root")
end

function M:update(dt) end

function M:on_input(action_id, action) return false end

function M:on_style_change(style) end

function M:on_message(message_id, message, sender) end

function M:on_language_change() end

function M:on_layout_change() end

function M:on_window_resized() end

function M:on_input_interrupt() end

function M:on_focus_lost() end

function M:on_focus_gained() end

function M:on_remove() end

return M
```

### 生成自定义组件

创建自定义组件后，您可以在代码中生成它。例如，如果您有一个名为 `my_component` 的组件，您可以这样创建它：

```lua
local druid = require("druid.druid")
local my_component = require("my.amazing.component")

function init(self)
    self.druid = druid.new(self)
    self.druid:new(my_component, "template_name")
end
```

在上面的代码中，`template_name` 指的是 GUI 模板文件的名称，如果您在自定义组件中使用它的话。`nodes` 是从 `gui.clone_tree(node)` 获取的表。如果您为组件生成多个节点，请将表传递给组件构造函数。在组件内部，您需要使用 `self:set_template(template)` 和 `self:set_nodes(nodes)` 设置模板和节点。

### 注册自定义组件

您可以注册您的自定义组件，以便在不需在每个文件中要求组件模块的情况下使用它。注册组件对于游戏中非常基础的组件很方便。以下是您如何在 Druid 中注册自定义组件的方法：

```lua
local druid = require("druid.druid")
local my_component = require("my.amazing.component")

function init(self)
    -- 注册使"druid:new_{component_name}"函数可用
    druid.register("my_component", my_component)
end
```

一旦组件注册，一个名为"new\_{component_name}"的新函数将可用。在我们的示例中，它将是 `druid:new_my_component()`。组件注册后，您可以使用以下代码创建其实例：

```lua
local druid = require("druid.druid")
local my_component = require("my.amazing.component")

function init(self)
    self.druid = druid.new(self)
    self.my_component = self.druid:new_my_component(template, nodes)
end
```

## 使用模板的力量

使用 Druid，您可以使用单个组件但为其创建和自定义模板。模板只需要匹配组件方案。例如，您可以有一个名为 `player_panel` 的组件和两个名为 `player_panel` 和 `enemy_panel` 的 GUI 模板，它们有不同的布局。相同的组件脚本可用于两个模板。
