# 基本用法

本指南将帮助您开始使用 **Druid** UI框架。我们将介绍基本设置和使用模式。

## 初始设置

要使用 **Druid**，您需要在GUI脚本中创建一个 **Druid** 实例。此实例将处理所有组件管理和核心功能。

使用以下模板创建一个新的 `*.gui_script` 文件：

```lua
local druid = require("druid.druid")

function init(self)
    self.druid = druid.new(self)
end

function final(self)
    self.druid:final()
end

function update(self, dt)
    self.druid:update(dt)
end

function on_message(self, message_id, message, sender)
    self.druid:on_message(message_id, message, sender)
end

function on_input(self, action_id, action)
    return self.druid:on_input(action_id, action)
end
```

将此脚本添加到您的GUI场景中。现在您可以开始创建 **Druid** 组件。

> **注意：** 当向组件传递节点时，您可以使用节点名称字符串而不是 `gui.get_node()` 函数。

## 基本组件示例

这是一个简单的示例，展示如何创建和使用基本的 **Druid** 组件：

```lua
local druid = require("druid.druid")

-- 所有组件回调都将"self"作为第一个参数传递
-- 这个"self"是在`druid.new(context)`中传递的上下文数据
local function on_button_callback(self)
    -- 您应该使用`:`操作符调用组件的方法
    self.text:set_text("按钮被点击了！")
end

function init(self)
    self.druid = druid.new(self)
    -- 您可以使用node_id而不是gui.get_node():
    self.button = self.druid:new_button("button_node_id", on_button_callback)
    self.text = self.druid:new_text("text_node_id", "你好, Druid!")
end

function final(self)
    self.druid:final()
end

function update(self, dt)
    self.druid:update(dt)
end

function on_message(self, message_id, message, sender)
    self.druid:on_message(message_id, message, sender)
end

function on_input(self, action_id, action)
    return self.druid:on_input(action_id, action)
end
```

## 滚动与网格示例

```lua
local druid = require("druid.druid")

function init(self)
    self.druid = druid.new(self)

    -- `scroll_node_id`节点大小表示滚动可见区域，通常启用蒙版模式。
    -- `content_node_id`节点大小应大于scroll_node_id节点大小，表示可滚动区域。应该是`scroll_node_id`节点的子节点。
    self.scroll = self.druid:new_scroll("scroll_node_id", "content_node_id")

    -- `grid_parent_node_id`是网格项目的父节点。通常是滚动的内容节点。
    -- `item_prefab_node_id`是网格项目的预制节点。用于获取项目大小。
    self.grid = self.druid:new_grid("content_node_id", "item_prefab_node_id", 1)

    -- 将网格绑定到滚动。它将在网格更改时重新计算滚动大小。
    self.scroll:bind_grid(self.grid)

    for index = 1, 10 do
        local nodes = gui.clone_tree(gui.get_node("item_prefab_node_id"))
        local root = nodes["/root"] -- 根节点是项目节点。
        gui.set_enabled(root, true)
        self.grid:add(root)
    end
end
```

## 小部件

小部件是可重用的UI组件，封装了多个 **Druid** 组件。更多信息请参见[小部件](wiki/widgets.md)文档。

### 创建小部件

为您的小部件类创建一个新的Lua文件。该文件最好放在相应的GUI文件附近，使用相同的名称。您可以使用Druid的编辑器脚本来创建小部件，方法是在编辑器中右键单击GUI文件或在"Edit"菜单面板中（当GUI文件打开时）。

定义`init`函数来初始化小部件。

这是一个基本的小部件示例：

```lua
---@class best_widget_in_the_world: druid.widget
local M = {}

function M:init()
    self.root = self:get_node("root")

    -- 在您的小部件内创建按钮和文本组件
    self.button = self.druid:new_button("button_node_id", self.on_click)
    self.text = self.druid:new_text("text_node_id", "你好, Druid!")

    -- 它们现在可以在外部通过self.button和self.text访问
end

---"self"将在Druid的回调中正确调用
function M:on_click()
    self.text:set_text("按钮被点击了！")
end


---向小部件添加自己的函数
function M:say_hello()
    self.text:set_text("你好, Druid!")
end


return M
```

### 使用小部件

您可以在GUI脚本中创建小部件：

```lua
local druid = require("druid.druid")
local best_widget_in_the_world = require("widgets.best_widget_in_the_world")

function init(self)
    self.druid = druid.new(self)

    local my_widget_template_id_on_gui_scene = "best_widget_in_the_world"
    self.my_widget = self.druid:new_widget(best_widget_in_the_world, my_widget_template_id_on_gui_scene)

    -- 现在您可以使用小部件函数
    self.my_widget:say_hello()
end

function final(self)
    self.druid:final()
end

function update(self, dt)
    self.druid:update(dt)
end

function on_message(self, message_id, message, sender)
    self.druid:on_message(message_id, message, sender)
end

function on_input(self, action_id, action)
    return self.druid:on_input(action_id, action)
end
```

## 小部件模板

小部件可以使用在GUI场景中定义的模板。模板是定义小部件结构的节点集合。

### 使用模板

如果您有一个ID为`best_widget_in_the_world`的GUI模板，包含`button_node_id`和`text_node_id`节点，您可以这样使用它：

```lua
function init(self)
    self.druid = druid.new(self)
    self.my_widget = self.druid:new_widget(best_widget_in_the_world, "best_widget_in_the_world")

    self.my_widget.button.on_click:subscribe(function()
        print("我的自定义回调")
    end)
    self.my_widget.text:set_text("你好, 小部件!")
end
```

### 动态模板

对于动态创建的GUI模板（来自预制件），您可以直接将节点传递给小部件：

```lua
function init(self)
    self.druid = druid.new(self)
    self.prefab = gui.get_node("best_widget_in_the_world/root")
    local nodes = gui.clone_tree(self.prefab)
    self.my_widget = self.druid:new_widget(best_widget_in_the_world, "best_widget_in_the_world", nodes)
end
```

您也可以直接使用根节点ID或节点，它将被克隆并用作模板：

```lua
-- 从此模板传递根节点ID以进行克隆
self.my_widget = self.druid:new_widget(best_widget_in_the_world, "best_widget_in_the_world", "root")
-- 或传递要克隆的节点
self.my_widget = self.druid:new_widget(best_widget_in_the_world, "best_widget_in_the_world", self.prefab)
```

### 资产商店中的小部件

**Druid 小部件** 可以从[资产商店](https://github.com/Insality/asset-store)扩展安装。它是可以安装在您的项目中的小部件集合。

安装资产商店后，按`Project ▸ [Asset Store] Assets`打开资产商店窗口。

在此窗口中，您可以查看可用的小部件并将它们安装到您的项目中。这些小部件将以文件形式下载，因此您可以轻松编辑和调整它们以满足您的需求。
