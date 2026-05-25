# Druid 设置

![Druid 设置](media/druid_settings.png)

打开 **Edit → [Druid] Settings** 来配置Druid编辑器扩展：模板路径、哪些编辑器命令出现在菜单中，以及文档和支持的快速链接。

## 模板路径设置

从编辑器创建新的Druid资源时使用的路径。

- **小部件模板路径** — 新Druid小部件的模板。默认值：`/druid/templates/widget_full.lua.template`。如果你已经知道如何使用Druid，可以选择最小替代方案 `/druid/templates/widget.lua.template`。使用箭头按钮打开文件，或使用省略号选择另一个路径。
- **GUI脚本模板路径** — 新Druid GUI脚本的模板。默认值：`/druid/templates/druid.gui_script.template`。相同的按钮用于打开/浏览。

如果你使用自定义模板或不同的项目布局，请更改这些设置。

## 编辑器命令

复选框控制哪些Druid命令出现在编辑器中：

- **分配图层** — 在GUI文件（`.gui`）打开时从 **Edit → [Druid]** 运行。根据该GUI场景中使用的纹理和字体自动分配图层。
- **创建Druid小部件** — 在 **Asset** 窗格中右键单击 `.gui` 文件 → **[Druid] → Create Druid Widget**。在GUI文件旁边创建一个 `.lua` 文件。
- **创建Druid GUI脚本** — 右键单击 `.gui` 文件 → **[Druid] → Create Druid GUI Script**。在GUI文件旁边创建一个 `.gui_script` 并将其附加到GUI。
- **创建Druid集合** — 右键单击 `.gui` 文件 → **[Druid] → Create Druid Collection**。创建一个附有此GUI文件的集合。

取消勾选你不使用的选项以保持菜单最小化。

## 文档

- **项目仓库** — 在浏览器中打开Druid项目仓库。
- **打开快速API参考** — 在编辑器或默认应用程序中打开快速API参考（例如 `api/quick_api_reference.md`）。

## 支持项目

支持Druid的按钮：

- [**在GitHub上赞助**](https://github.com/sponsors/Insality)
- [**Ko-fi**](https://ko-fi.com/insality)
- [**Buy Me A Coffee**](https://www.buymeacoffee.com/insality)

使用 **Save** 应用更改，或使用 **Cancel** 丢弃更改。
