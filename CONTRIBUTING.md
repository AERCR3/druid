# 为Druid做贡献

感谢您有兴趣为 **Druid** 做出贡献！我们欢迎各种规模的贡献 - 即使是小的修复也能带来很大差异。

## 目录

- [如何报告问题](#how-to-report-issues)
- [小修复](#small-fixes)
- [更大贡献](#larger-contributions)
- [文档更新](#documentation-updates)
- [添加或更新示例](#adding-or-updating-examples)
- [单元测试](#unit-tests)

## 如何报告问题

发现了一个bug？请通过以下信息向我们的 [问题跟踪器](https://github.com/druid-js/druid/issues) 报告：

- 问题的清晰描述
- 重现问题的步骤
- 期望行为与实际行为
- 您的环境（Defold版本、操作系统等）

## 小修复

**我们强烈鼓励小的改进！** 对于错误修复、拼写更正或小的改进，您可以直接向 `master` 或 `develop` 分支提交拉取请求。

进行这些贡献时，您**必须**：

1. 更新补丁版本号：
   - `README.md` 文件（在依赖项部分）
   - `game.project` 文件（在项目部分）
2. 将您的更改添加到 `wiki/changelog.md`
3. 这些步骤对于正确标记新版本是必需的

**版本更新示例：**

对于README.md：

```
# 之前
https://github.com/Insality/druid/archive/refs/tags/1.1.0.zip

# 之后（补丁版本增加）
https://github.com/Insality/druid/archive/refs/tags/1.1.1.zip
```

对于game.project：

```
# 之前
[project]
title = Druid
version = 1.1.0

# 之后（补丁版本增加）
[project]
title = Druid
version = 1.1.1
```

## 更大贡献

对于新功能、重大改进或复杂修复：

1. Fork仓库
2. 从 `develop` 创建分支
3. 进行您的更改
4. 确保代码遵循项目风格指南
5. 彻底测试您的更改
6. 向 `develop` 分支提交拉取请求
7. 包含任何相关问题的引用（例如，"Fixes #123"）

请保持更改专注于解决特定问题或功能，并保持现有代码风格。

## 文档更新

要改进文档：

1. Fork仓库
2. 为您的更改创建分支
3. 更新相关的文档文件
4. 向 `master` 或 `develop` 分支提交拉取请求

清晰、准确的文档对每个人都有帮助，所以文档改进总是受到赞赏！

## 添加或更新示例

示例对于帮助用户了解如何使用Druid至关重要。每个示例应包括：

1. 带有Druid小部件的GUI场景
2. `examples_list.lua` 中的示例信息

要添加新示例：

1. 在 `/example/examples` 目录中创建新的GUI文件
2. 将示例信息添加到 `examples_list.lua`
3. 在 `/example/druid.gui` 中包含您的GUI模板
   - 将其放置在适当的层次结构中：`root -> container_center -> examples -> widgets`
4. 通过运行游戏测试您的示例
5. 向 `develop` 分支提交拉取请求

## 单元测试

单元测试有助于确保Druid正常工作。如果您遇到问题，单元测试可以是一个很好的起点来理解或重现它。

所有测试都位于 `/test/tests` 目录中。

运行测试：

1. 将引导集合设置为 `/test/test.collection`
2. 运行项目

提交新测试或更新测试：

1. 为您的更改创建分支
2. 添加或修改测试
3. 验证您的测试通过
4. 向 `develop` 分支提交拉取请求

---

感谢您为让Druid变得更好而做出贡献！❤️
