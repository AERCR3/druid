[![](media/druid_logo.png)](https://insality.github.io/druid/)

[![GitHub release (latest by date)](https://img.shields.io/github/v/tag/insality/druid?style=for-the-badge&label=Release)](https://github.com/Insality/druid/tags)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/insality/druid/ci-workflow.yml?branch=master&style=for-the-badge)](https://github.com/Insality/druid/actions)
[![codecov](https://img.shields.io/codecov/c/github/Insality/druid?style=for-the-badge)](https://codecov.io/gh/Insality/druid)

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/insality) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/insality) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/insality)

**Druid** - 一个强大、灵活且易于使用的 **Defold** 组件UI框架。包含广泛的UI组件，可用于创建美观、响应式和可自定义的GUI。提供了创建、组合和管理自定义组件和场景的强大方法。

## Druid 示例

查看 **Druid** 示例应用的 [**HTML5版本**](https://insality.github.io/druid/)。

在此示例中，您可以检查各种 **Druid** 组件并查看它们如何工作。每个示例页面都提供相应示例代码的直接链接，使您更容易理解如何使用 **Druid**。

## 特性

- **丰富的组件** - 提供大量组件，从基本按钮到无限数据列表和富文本
- **可定制** - 您可以通过API和样式自定义组件外观和行为
- **组件化** - 创建自己的可重用组件的强大方式
- **输入处理** - 以堆栈方式处理输入并管理输入优先级
- **基于事件** - 使用 [Defold Event](https://github.com/Insality/defold-event) 进行组件回调和组件间通信

## 快速链接

- [基本用法](wiki/basic_usage.md)
- [快速API参考](api/quick_api_reference.md)
- [组件列表](#druid-components)
- [贡献者](#contributors)

## 安装配置

### [依赖项](https://defold.com/manuals/libraries/#setting-up-library-dependencies)

> 可以通过 [Asset Store](https://github.com/Insality/asset-store) 扩展安装来跳过此步骤。

打开您的 `game.project` 文件，并在项目部分的依赖项字段中添加以下行：

**[Defold Event](https://github.com/Insality/defold-event)**

```
https://github.com/Insality/defold-event/archive/refs/tags/14.zip
```

**[Druid](https://github.com/Insality/druid/)**

```
https://github.com/Insality/druid/archive/refs/tags/1.2.0.zip
```

之后，选择 `Project ▸ Fetch Libraries` 来更新 [库依赖项](<(https://defold.com/manuals/libraries/#setting-up-library-dependencies)>)。每当您打开项目时都会自动执行此操作，因此只有在不重新打开项目的情况下依赖项发生变化时才需要执行此操作。

以下是 [所有发布版本](https://github.com/Insality/druid/releases) 的列表。

### 库大小

> **注意：** 库大小是基于每个平台的构建报告计算的。完整大小包含所有组件，如果不需要它们，可以在构建过程中删除。

| 平台            | 完整大小      |
| --------------- | ------------- |
| HTML5           | **84.52 KB**  |
| 桌面端 / 移动端 | **141.03 KB** |

### 输入绑定

**Druid** 使用 `/builtins/input/all.input_binding` 输入绑定。要么通过将 `game.project` 输入部分中的 `Runtime -> Input -> Game Binding` 字段设置为 `/builtins/input/all.input_binding` 来为此文件用于您的项目，要么将您需要的特定绑定添加到游戏的输入绑定文件中。对于自定义输入绑定，请参阅 [高级设置](https://github.com/Insality/druid/blob/master/wiki/advanced-setup.md#input-bindings) 中的输入绑定部分。

## 使用方法

### 基本用法

使用此代码作为您的 `gui_script` 文件的起点：

```lua
local druid = require("druid.druid")

function init(self)
    self.druid = druid.new(self)

    -- 在此处创建您的组件
    self.button = self.druid:new_button("button_node_id", function(self)
        print("按钮被点击！")
    end)

    self.text = self.druid:new_text("text_node_id", "Hello, Druid!")
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

阅读 [基本用法](wiki/basic_usage.md) 以了解如何使用 **Druid**，如何创建自己的组件以及如何使用组件化开发。

### API 文档

最佳起点是 [快速API参考](api/quick_api_reference.md)

以下是一些快速链接：

- [Druid 实例](api/druid_instance_api.md) - 从 `druid.new(self)` 返回的 **Druid** 实例
- [助手](api/druid_helper_api.md) - 许多有用的函数
- [Druid 颜色](api/druid_color_api.md) - 颜色实用函数
- [组件化](wiki/widgets.md) - 关于组件化及如何使用它们

## Druid 组件

这里是完整的 **Druid** 组件列表。

### 组件

| 名称                                                       | 描述                                                                                    | 示例                                                                                      | <div style="width:200px">预览</div>                                 |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **[按钮](/api/components/base/button_api.md)**             | GUI节点上的逻辑。处理用户点击交互：点击、长按、双击等。                                 | [按钮示例](https://insality.github.io/druid/?example=ui_example_basic_button)             | <img src="media/preview/button.gif" width="200" height="100">       |
| **[文本](/api/components/base/text_api.md)**               | GUI文本上的逻辑。默认情况下，文本组件使用不同的调整模式将文本适配到文本节点大小区域内。 | [文本示例](https://insality.github.io/druid/?example=ui_example_basic_text)               | <img src="media/preview/text.gif" width="200" height="100">         |
| **[滚动](/api/components/base/scroll_api.md)**             | 两个GUI节点上的逻辑：输入和内容。为可滚动内容提供基本行为。                             | [滚动示例](https://insality.github.io/druid/?example=ui_example_basic_scroll)             | <img src="media/preview/scroll.gif" width="200" height="100">       |
| **[阻挡器](/api/components/base/blocker_api.md)**          | GUI节点上的逻辑。不将任何用户输入传递到节点区域下方。                                   | [阻挡器示例](https://insality.github.io/druid/?example=ui_example_basic_blocker)          | <img src="media/preview/blocker.gif" width="200" height="100">      |
| **[返回处理器](/api/components/base/back_handler_api.md)** | 在用户"返回"操作上调用回调。它是Android返回按钮或键盘退格键                             | [返回处理器示例](https://insality.github.io/druid/?example=ui_example_basic_back_handler) | <img src="media/preview/back_handler.gif" width="200" height="100"> |
| **[静态网格](/api/components/base/static_grid_api.md)**    | GUI节点上的逻辑。管理所有节点大小相等的节点位置的组件。                                 | [静态网格示例](https://insality.github.io/druid/?example=ui_example_basic_grid)           | <img src="media/preview/static_grid.gif" width="200" height="100">  |
| **[悬停](/api/components/base/hover_api.md)**              | GUI节点上的逻辑。处理节点上的悬停操作。适用于移动触摸和鼠标指针。                       | [悬停示例](https://insality.github.io/druid/?example=ui_example_basic_hover)              | <img src="media/preview/hover.gif" width="200" height="100">        |
| **[滑动](/api/components/extended/swipe_api.md)**          | GUI节点上的逻辑。处理节点上的滑动手势。                                                 | [滑动示例](https://insality.github.io/druid/?example=ui_example_basic_swipe)              | <img src="media/preview/swipe.gif" width="200" height="100">        |
| **[拖拽](/api/components/base/drag_api.md)**               | GUI节点上的逻辑。处理拖动输入操作。可用于制作屏幕控制。                                 | [拖拽示例](https://insality.github.io/druid/?example=ui_example_basic_drag)               | <img src="media/preview/drag.gif" width="200" height="100">         |
| **[数据列表](/api/components/extended/data_list_api.md)**  | 滚动和网格组件上的逻辑。仅创建可见的GUI节点或组件以实现"无限"滚动行为                   | [数据列表示例](https://insality.github.io/druid/?example=ui_example_data_list_basic)      | <img src="media/preview/data_list.gif" width="200" height="100">    |
| **[输入](/api/components/extended/input_api.md)**          | GUI节点和GUI文本（或文本组件）上的逻辑。提供基本的用户文本输入。                        | [输入示例](https://insality.github.io/druid/?example=ui_example_basic_input)              | <img src="media/preview/input.gif" width="200" height="100">        |
| **[语言文本](/api/components/extended/lang_text_api.md)**  | 文本组件上的逻辑以处理本地化。可以使用 `druid.on_language_change` 实时翻译              | [语言文本示例](https://insality.github.io/druid/?example=ui_example_window_language)      | <img src="media/preview/lang_text.gif" width="200" height="100">    |
| **[进度条](/api/components/extended/progress_api.md)**     | GUI节点上的逻辑。处理节点大小和比例以处理进度节点大小。                                 | [进度条示例](https://insality.github.io/druid/?example=ui_example_basic_progress_bar)     | <img src="media/preview/progress.gif" width="200" height="100">     |
| **[滑块](/api/components/extended/slider_api.md)**         | GUI节点上的逻辑。处理带有位置限制的可拖动节点。                                         | [滑块示例](https://insality.github.io/druid/?example=ui_example_basic_slider)             | <img src="media/preview/slider.gif" width="200" height="100">       |
| **[计时器](/api/components/extended/timer_api.md)**        | GUI文本上的逻辑。处理基本计时器功能。                                                   | [计时器示例](https://insality.github.io/druid/?example=ui_example_basic_timer)            | <img src="media/preview/timer.gif" width="200" height="100">        |
| **[热键](/api/components/extended/hotkey_api.md)**         | 允许为带按键修饰符的键盘热键设置回调。                                                  | [热键示例](https://insality.github.io/druid/?example=ui_example_basic_hotkey)             | <img src="media/preview/hotkey.gif" width="200" height="100">       |
| **[布局](/api/components/extended/layout_api.md)**         | GUI节点上的逻辑。使用边距/内边距设置在布局节点内排列节点。                              | [布局示例](https://insality.github.io/druid/?example=ui_example_layout_basic)             | <img src="media/preview/layout.gif" width="200" height="100">       |
| **[富输入](/api/components/custom/rich_input_api.md)**     | GUI节点和GUI文本（或文本组件）上的逻辑。提供带不同样式和文本格式的富文本输入。          | [富输入示例](https://insality.github.io/druid/?example=ui_example_basic_rich_input)       | <img src="media/preview/rich_input.gif" width="200" height="100">   |
| **[富文本](/api/components/custom/rich_text_api.md)**      | GUI文本上的逻辑。提供带不同样式和文本格式的富文本格式化。                               | [富文本次示例](https://insality.github.io/druid/?example=ui_example_basic_rich_text)      | <img src="media/preview/rich_text.gif" width="200" height="100">    |

## Druid 事件

所有 **Druid** 组件使用 [Defold Event](https://github.com/Insality/defold-event) 进行组件回调。在组件API（[按钮示例](/api/components/base/button_api.md#fields)）中列出了组件事件。您可以使用以下API手动订阅这些事件：

- **event:subscribe**(回调函数)

- **event:unsubscribe**(回调函数)

您可以将多个回调函数订阅到单个事件。

示例：

```lua
button.on_click:subscribe(function(self, args)
	print("按钮被点击！")
end)

scroll.on_scroll:subscribe(function(self, position)
	print("滚动条已滚动！")
end)

input.on_input_unselect:subscribe(function(self, text)
	print("用户输入:", text)
end)
```

## 详细信息

- **Druid** 以基于堆栈的方式处理输入。最近创建的按钮将首先被检查。从前到后创建您的输入GUI组件。
- 记住在 `on_input` 函数中包含 `return`：`return self.druid:on_input()`。如果存在多个输入源（多个Druid实例，其他输入系统等），这是必需的。
- 如果您有输入组件，Druid会自动调用 `acquire_input_focus`。因此，不需要手动调用 `acquire_input_focus`。
- 删除 **Druid** 组件节点时，请确保使用 `druid:remove(component)` 移除它。

## 示例

尝试 **Druid** 示例应用的 [**HTML5版本**](https://insality.github.io/druid/)。

每个示例页面都提供相应示例代码的直接链接，使您更容易理解如何使用 **Druid**。

或者直接参考 [**示例文件夹**](https://github.com/Insality/druid/tree/develop/example) 获取演示如何使用 **Druid** 的代码示例。

## 文档

您可以在 [快速API参考](api/quick_api_reference.md) 中找到完整的 **Druid** 函数

为了更好地理解 **Druid**，请阅读以下文档：

- [Druid 工作坊](https://youtu.be/qF19qpjZe9c) - 一小时的视频来了解 **Druid** 的所有基础知识。包含大量示例和解释。
- [如何在Defold中制作GUI](https://forum.defold.com/t/how-to-gui-in-defold/73256)
- [组件化](wiki/widgets.md)
- [Druid 样式](wiki/styles.md)
- [高级设置](wiki/advanced-setup.md)
- [Druid 设置](wiki/druid_settings.md)
- [优化Druid大小](wiki/optimize_druid_size.md)
- [变更日志](wiki/changelog.md)

## 许可证

该项目根据MIT许可证授权 - 有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

## 问题和建议

如果您有任何问题、疑问或建议，请 [创建问题](https://github.com/Insality/druid/issues)

## 历史

有关 **Druid** 开发的完整历史，请查看 [变更日志](wiki/changelog.md)。

## 贡献者

原始Druid想法来自 [AGulev](https://github.com/AGulev)

特别感谢所有帮助使 **Druid** 变得更好的贡献者！

<a href="https://github.com/Insality/druid/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=insality/druid"/>
</a>

阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 文件获取更多信息。

## ❤️ 支持项目 ❤️

Druid由一名开发者在业余时间开发和维护。

如果这个库对您的项目有帮助，请考虑支持我的工作 ❤️

这真的很重要。

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/insality) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/insality) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/insality)
