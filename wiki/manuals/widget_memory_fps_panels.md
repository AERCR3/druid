# 内存和帧率面板组件

`Druid 1.1` 包含了两个内置组件：`内存面板` 和 `帧率面板`，它们允许您监控游戏中的内存和帧率(FPS)。

Druid 中的组件通常由两个文件组成：GUI文件，用作GUI场景中的模板；以及Lua脚本，用于与Druid一起创建组件。

<!-- 视频 -->

## 内存面板

`内存面板` 是一个允许您监控游戏内存的组件。它以图表形式显示最近3秒内的内存分配情况、最大的内存分配步骤、总Lua内存和每秒内存使用量。

当您在图表中看到空白区域时，这意味着垃圾回收器正在此时工作。

### 如何添加：

- 将 `/druid/widget/memory_panel/memory_panel.gui` 添加到您的 `*.gui` 场景中

![](/wiki/manuals/media/memory_fps_panel_add.png)
![](/wiki/manuals/media/memory_fps_panel_select.png)

- 如有需要，您可以调整模板的比例
- 在 `*.gui_script` 中添加Druid和组件设置
```lua
local druid = require("druid.druid")
local memory_panel = require("druid.widget.memory_panel.memory_panel")

function init(self)
	self.druid = druid.new(self)
	-- "memory_panel" 是GUI场景中模板的名称，通常与模板文件名匹配
	self.memory_panel = self.druid:new_widget(memory_panel, "memory_panel")
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

并确保：
- `*.gui_script` 已附加到您的 `*.gui` 场景
- GUI组件已添加到您的游戏场景中


## 帧率面板

`帧率面板` 是一个允许您监控游戏帧率(FPS)的组件。它显示最近3秒内的帧率图、最低和当前帧率值

### 如何添加：

- 将 `/druid/widget/fps_panel/fps_panel.gui` 添加到您的 `*.gui` 场景中
- 如有需要，您可以调整模板的比例
- 在 `*.gui_script` 中添加Druid和组件设置
```lua
local druid = require("druid.druid")
local fps_panel = require("druid.widget.fps_panel.fps_panel")

function init(self)
	self.druid = druid.new(self)
	-- "fps_panel" 是GUI场景中模板的名称，通常与模板文件名匹配
	self.fps_panel = self.druid:new_widget(fps_panel, "fps_panel")
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

并确保：
- `*.gui_script` 已附加到您的 `*.gui` 场景
- GUI组件已添加到您的游戏场景中

这些组件不仅可以用于开发和分析游戏性能，还可以作为如何使用Druid创建自定义组件并在游戏中使用它们的示例。

感谢阅读！