# 小部件

小部件是可重用的UI组件，可简化游戏中用户界面的创建和管理。

## 什么是小部件

在小部件之前，有"自定义组件"。小部件替换了自定义组件。基本上，它们是相同的东西，唯一的区别在于它们的初始化方式。

让我们看看基本的自定义组件模板：

```lua
local component = require("druid.component")

---@class my_component: druid.component
local M = component.create("my_component")

function M:init(template, nodes)
    self:set_template(template)
    self:set_nodes(nodes)
    self.druid = self:get_druid()

    self.druid:new_button("button_node_name", self.on_click)
end

function M:on_click()
	print("当前输出字符串: " .. self.output_string)
end

function M:set_output_string(output_string)
    self.output_string = output_string
end
```

基本组件使用 `druid:new()` 函数创建：

```lua
local template = "my_component" -- GUI场景中的模板名称，如果是nil则直接通过gui.get_node()获取
local nodes = gui.clone_tree(gui.get_node("my_component/root")) -- 我们可以克隆组件节点并在克隆的节点上初始化

local my_component = druid:new("my_component", template, nodes)
my_component:set_output_string("Hello world!")
```

现在，让我们看看如何使用小部件：

```lua
---@type my_widget: druid.widget
local M = {}

function M:init()
    self.druid:new_button("button_node_name", self.on_click)
	self.output_string = ""
end

function M:on_click()
    print("当前输出字符串: " .. self.output_string)
end

function M:set_output_string(output_string)
    self.output_string = output_string
end

return M
```

就是这样！相同的功能，但没有任何样板代码，只是一个Lua表。Druid实例、模板和节点已经创建并可用。

你可以像这样创建自己的小部件：

```lua
local druid = require("druid.druid")
local my_widget = require("widgets.my_widget.my_widget")

function init(self)
    self.druid = druid.new(self)
	local template_id = "my_widget" -- 如果使用GUI模板，设置模板ID，否则设置为nil
	local nodes = nil -- 如果节点是通过gui.clone_tree()克隆的，设置节点表，否则设置为nil
    self.my_widget = self.druid:new_widget(my_widget, template_id, nodes)
    self.my_widget:set_output_string("Hello world!")
end
```

所以现在使用小部件创建UI组件比使用自定义组件更容易、更简洁。

## 创建新小部件

让我们从头开始。小部件通常由2部分组成：

1. GUI场景
2. 小部件Lua模块

创建一个小部件的GUI场景（用户头像面板、商店窗口、游戏面板菜单等）。按照你的意愿设计它，但建议添加一个ID为`root`的`root`节点，并将所有其他节点作为此节点的子节点。这使得处理小部件更加容易。此外，这个根节点通常代表小部件的大小，因此建议将其大小设置为小部件的所需大小。

让我们通过在GUI场景文件旁边创建一个新文件来创建一个小部件：

```lua
-- my_widget.lua
local M = {}

function M:init()
    self.root = self:get_node("root")
    self.button = self.druid:new_button("button_open", self.open_widget, self)
end

function M:open_widget()
    print("打开小部件被按下")
end

return M
```

这就是基本的创建过程。现在我们有了一个小部件，在这里我们可以访问根节点并使用"button_open"节点作为按钮。

现在，让我们在游戏场景中创建一个小部件。

在主场景上放置一个小部件（GUI模板）。然后导入Druid并使用放置在场景上的GUI模板创建一个新的小部件实例：

```lua
local druid = require("druid.druid")
local my_widget = require("widgets.my_widget.my_widget")

function init(self)
    self.druid = druid.new(self)
    self.my_widget = self.druid:new_widget(my_widget, "my_widget")

    -- 如果我们想要克隆它并多次使用，我们可以传递节点表
    local array_of_widgets = {}
    for index = 1, 10 do
        -- 对于小部件，现在我们可以直接使用my_widget内的根节点，而不是手动克隆节点
        local widget = self.druid:new_widget(my_widget, "my_widget", "root")
        table.insert(array_of_widgets, widget)
    end
end
```

## 不使用GUI模板使用小部件

可以在不使用GUI模板的情况下使用小部件。此小部件可以从父实例中选择节点。

```lua
-- my_widget.lua
local event = require("event.event")

local M = {}

function M:init()
    self.on_close = event.create()
    self.druid:new_hotkey("key_backspace", self.on_close)
end

return M
```

```lua
-- gui_script
local druid = require("druid.druid")
local my_widget = require("widgets.my_widget.my_widget")

local function on_close()
	print("小部件已关闭")
end

function init(self)
    self.druid = druid.new(self)
    self.my_widget = self.druid:new_widget(my_widget)
	self.my_widget.on_close:subscribe(on_close, self)
end
```

## 创建Druid小部件编辑器脚本

Druid提供了一个编辑器脚本来帮助您为GUI场景创建Lua文件。您可以在处理\*.gui场景时在菜单`Edit -> Create Druid Widget`下找到命令。

此脚本将创建一个具有相同名称和基本模板的新小部件lua文件。

Druid提供两个模板：

- `/druid/templates/widget.lua.template` - 小部件的基本模板。
- `/druid/templates/widget_full.lua.template` - 小部件的完整模板。

您可以在`Edit`菜单中的`[Druid] Settings`选项中更改模板路径。
