# 快速API参考

# 目录

1. [Druid](#druid)
2. [Druid实例](#druid-实例)
3. [组件](#组件)
   1. [基础组件](#基础组件)
   2. [阻挡器](#阻挡器)
   3. [按钮](#按钮)
   4. [容器](#容器)
   5. [数据列表](#数据列表)
   6. [拖拽](#拖拽)
   7. [网格](#网格)
   8. [热键](#热键)
   9. [悬停](#悬停)
   10. [输入](#输入)
   11. [语言文本](#语言文本)
   12. [布局](#布局)
   13. [进度条](#进度条)
   14. [富输入](#富输入)
   15. [富文本](#富文本)
   16. [滚动](#滚动)
   17. [滑块](#滑块)
   18. [滑动](#滑动)
   19. [文本](#文本)
   20. [计时器](#计时器)
4. [助手](#助手)
5. [Druid颜色](#druid-颜色)

# API参考

## [Druid](druid_api.md)

查看 [API](druid_api.md)

```lua
local druid = require("druid.druid")

druid.init_window_listener()               -- 初始化窗口监听器
druid.on_language_change()                 -- 处理语言变化
druid.on_window_callback(window_event)     -- 处理窗口回调事件
druid.set_default_style(style)             -- 设置默认样式
druid.set_sound_function(callback)         -- 设置声音函数
druid.set_text_function(callback)          -- 设置文本函数

self.druid = druid.new(context, [style])   -- 创建新的druid实例
```

## [Druid实例](druid_instance_api.md)

查看 [API](druid_instance_api.md)

```lua
-- 生命周期
self.druid:final()                                         -- 销毁druid实例
self.druid:update(dt)                                      -- 更新druid实例
self.druid:on_input(action_id, action)                     -- 处理输入事件
self.druid:on_message(message_id, message, sender)         -- 处理消息

-- 自定义组件
self.druid:new(component, ...)                             -- 创建新组件
self.druid:new_widget(widget, [template], [nodes], ...)    -- 创建新部件

-- 内置组件
self.druid:new_button(node, [callback], [params], [anim_node])                    -- 创建新按钮组件
self.druid:new_text(node, [value], [no_adjust])                                  -- 创建新文本组件
self.druid:new_grid(parent_node, item, [in_row])                                 -- 创建新网格组件
self.druid:new_scroll(view_node, content_node)                                   -- 创建新滚动组件
self.druid:new_data_list(druid_scroll, druid_grid, create_function)                -- 创建新数据列表组件
self.druid:new_progress(node, key, [init_value])                                 -- 创建新进度条组件
self.druid:new_lang_text(node, [locale_id], [adjust_type])                        -- 创建新语言文本组件
self.druid:new_rich_text(text_node, [value])                                     -- 创建新富文本组件
self.druid:new_back_handler([callback], [params])                                -- 创建新返回处理器
self.druid:new_blocker(node)                                                     -- 创建新阻挡器组件
self.druid:new_hover(node, [on_hover_callback], [on_mouse_hover_callback])       -- 创建新悬停组件
self.druid:new_drag(node, [on_drag_callback])                                    -- 创建新拖拽组件
self.druid:new_swipe(node, [on_swipe_callback])                                  -- 创建新滑动组件
self.druid:new_input(click_node, text_node, [keyboard_type])                     -- 创建新输入组件
self.druid:new_rich_input(template, [nodes])                                     -- 创建新富输入组件
self.druid:new_layout(node, [mode])                                              -- 创建新布局组件
self.druid:new_container(node, [mode], [callback])                               -- 创建新容器组件
self.druid:new_hotkey(keys_array, [callback], [callback_argument])               -- 创建新热键组件
self.druid:new_slider(pin_node, end_pos, [callback])                             -- 创建新滑块组件
self.druid:new_timer(node, [seconds_from], [seconds_to], [callback])             -- 创建新计时器组件

-- 操作
self.druid:remove(component)                           -- 移除组件
self.druid:set_blacklist(blacklist_components)         -- 设置组件黑名单
self.druid:set_whitelist(whitelist_components)         -- 设置组件白名单
```

## 组件

### [基础组件](components/base/component_api.md)

查看 [API](components/base/component_api.md)

所有组件和小部件的基本方法。

```lua
component:get_childrens()                    -- 获取子组件列表
component:get_context()                      -- 获取上下文
component:get_druid([template], [nodes])     -- 获取druid实例
component:get_input_priority()               -- 获取输入优先级
component:get_node(node_id)                  -- 根据ID获取节点
component:get_nodes()                        -- 获取所有节点
component:get_parent_component()             -- 获取父组件
component:get_template()                     -- 获取模板
component:reset_input_priority()             -- 重置输入优先级
component:set_input_enabled(state)           -- 设置输入启用状态
component:set_input_priority(value, [is_temporary])  -- 设置输入优先级
component:set_nodes(nodes)                   -- 设置节点
component:set_style([druid_style])           -- 设置样式
component:set_template([template])           -- 设置模板

-- 所有小部件都随创建的Druid实例一起提供
-- 所有其他组件的功能也存在
widget.druid
```

### [阻挡器](components/base/blocker_api.md)

查看 [API](components/base/blocker_api.md)

```lua
local blocker = self.druid:new_blocker(node)

blocker:is_enabled()                         -- 检查阻挡器是否启用
blocker:set_enabled(state)                   -- 设置阻挡器启用状态
```

### [按钮](components/base/button_api.md)

查看 [API](components/base/button_api.md)

```lua
local button = require("druid.base.button")

button:init(node_or_node_id, [callback], [custom_args], [anim_node])  -- 初始化按钮
button:set_animations_disabled()                                    -- 禁用动画
button:set_enabled([state])                                          -- 设置按钮启用状态
button:is_enabled()                                                  -- 检查按钮是否启用
button:set_click_zone([zone])                                        -- 设置点击区域
button:set_key_trigger(key)                                          -- 设置按键触发器
button:get_key_trigger()                                             -- 获取按键触发器
button:set_check_function([check_function], [failure_callback])      -- 设置检查函数
button:set_web_user_interaction([is_web_mode])                       -- 设置网页用户交互模式
button:button_hover(hover_state)                                     -- 处理按钮悬停状态
button:button_mouse_hover(hover_state)                              -- 处理鼠标悬停状态
button:button_click()                                                -- 处理按钮点击
button:button_repeated_click()                                       -- 处理重复点击
button:button_long_click()                                           -- 处理长按点击
button:button_double_click()                                         -- 处理双击
button:button_hold(press_time)                                       -- 处理按钮按住

button.on_click                                                      -- 点击回调
button.on_pressed                                                    -- 按下回调
button.on_repeated_click                                             -- 重复点击回调
button.on_long_click                                                 -- 长按回调
button.on_double_click                                               -- 双击回调
button.on_hold_callback                                              -- 按住回调
button.on_click_outside                                              -- 点击外部回调
```

### [容器](components/extended/container_api.md)

查看 [API](components/extended/container_api.md)

```lua
local container = self.druid:new_container(node, [mode], [callback])

container:add_container(node_or_container, [mode], [on_resize_callback])    -- 添加容器
container:clear_draggable_corners()                                        -- 清除可拖拽角落
container:create_draggable_corners()                                       -- 创建可拖拽角落
container:fit_into_node(node)                                              -- 适配到节点大小
container:fit_into_size(target_size)                                       -- 适配到指定尺寸
container:fit_into_window()                                                -- 适配到窗口大小
container:get_position()                                                   -- 获取位置
container:get_scale()                                                      -- 获取缩放
container:get_size()                                                       -- 获取尺寸
container:on_window_resized()                                              -- 窗口调整大小时的回调
container:refresh()                                                        -- 刷新容器
container:refresh_origins()                                                -- 刷新原点
container:refresh_scale()                                                  -- 刷新缩放
container:remove_container_by_node([node])                                 -- 根据节点移除容器
container:set_min_size([min_size_x], [min_size_y])                        -- 设置最小尺寸
container:set_max_size([max_size_x], [max_size_y])                        -- 设置最大尺寸
container:set_parent_container([parent_container])                         -- 设置父容器
container:set_pivot(pivot)                                                 -- 设置轴心点
container:set_position(pos_x, pos_y)                                       -- 设置位置
container:set_size([width], [height], [anchor_pivot])                     -- 设置尺寸
container:update_child_containers()                                        -- 更新子容器

container.on_size_changeed                                                 -- 尺寸改变回调
```

### [数据列表](components/extended/data_list_api.md)

查看 [API](components/extended/data_list_api.md)

```lua
local data_list = self.druid:new_data_list(druid_scroll, druid_grid, create_function)

data_list:add(data, [index], [shift_policy])                          -- 添加数据
data_list:clear()                                                     -- 清空数据
data_list:get_created_components()                                    -- 获取已创建的组件
data_list:get_created_nodes()                                         -- 获取已创建的节点
data_list:get_data()                                                  -- 获取数据
data_list:get_index(data)                                             -- 获取数据索引
data_list:remove([index], [shift_policy])                            -- 移除数据
data_list:remove_by_data(data, [shift_policy])                       -- 根据数据移除
data_list:scroll_to_index(index)                                      -- 滚动到指定索引
data_list:set_data(data)                                              -- 设置数据
data_list:set_use_cache(is_use_cache)                                -- 设置是否使用缓存

data_list.on_scroll_progress_change                                   -- 滚动进度改变回调
data_list.on_element_add                                              -- 元素添加回调
data_list.on_element_remove                                           -- 元素移除回调
```

### [拖拽](components/base/drag_api.md)

查看 [API](components/base/drag_api.md)

```lua
local drag = self.druid:new_drag(node, [on_drag_callback])

drag:is_enabled()                              -- 检查是否启用拖拽
drag:on_window_resized()                       -- 窗口调整大小时的回调
drag:set_click_zone([node])                    -- 设置点击区域
drag:set_drag_cursors(is_enabled)              -- 设置拖拽光标
drag:set_enabled(is_enabled)                   -- 设置拖拽启用状态

drag.on_touch_start                            -- 触摸开始回调
drag.on_touch_end                              -- 触摸结束回调
drag.on_drag_start                             -- 拖拽开始回调
drag.on_drag                                   -- 拖拽回调
drag.on_drag_end                               -- 拖拽结束回调
```

### [网格](components/base/static_grid_api.md)

查看 [API](components/base/static_grid_api.md)

```lua
local grid = self.druid:new_grid(parent_node, item, [in_row])

grid:add(item, [index], [shift_policy], [is_instant])           -- 添加项目
grid:clear()                                                    -- 清空网格
grid:get_items_count()                                          -- 获取项目数量
grid:get_all_pos()                                              -- 获取所有位置
grid:get_borders()                                              -- 获取边界
grid:get_index(pos)                                             -- 根据位置获取索引
grid:get_index_by_node(node)                                    -- 根据节点获取索引
grid:get_offset()                                               -- 获取偏移量
grid:get_pos(index)                                             -- 根据索引获取位置
grid:get_size()                                                 -- 获取网格尺寸
grid:get_size_for([count])                                      -- 根据数量获取尺寸
grid:refresh()                                                  -- 刷新网格
grid:remove(index, [shift_policy], [is_instant])                -- 移除项目
grid:set_anchor(anchor)                                         -- 设置锚点
grid:set_in_row(in_row)                                         -- 设置每行项目数
grid:set_item_size([width], [height])                           -- 设置项目尺寸
grid:set_items(nodes, [is_instant])                             -- 设置项目节点
grid:set_pivot([pivot])                                         -- 设置轴心点
grid:set_position_function(callback)                            -- 设置位置函数
grid:sort_nodes(comparator)                                     -- 排序节点

grid.on_add_item                                                -- 添加项目回调
grid.on_remove_item                                             -- 移除项目回调
grid.on_change_items                                            -- 项目改变回调
grid.on_clear                                                   -- 清空回调
grid.on_update_positions                                        -- 位置更新回调
```

### [热键](components/extended/hotkey_api.md)

查看 [API](components/extended/hotkey_api.md)

```lua
local hotkey = self.druid:new_hotkey(keys_array, [callback], [callback_argument])

hotkey:add_hotkey(keys, [callback_argument])            -- 添加热键
hotkey:bind_node([node])                                -- 绑定节点
hotkey:is_processing()                                  -- 检查是否正在处理
hotkey:on_focus_gained()                                -- 获得焦点时的回调
hotkey:set_repeat(is_enabled_repeated)                  -- 设置是否重复

hotkey.on_hotkey_pressed                                -- 热键按下回调
hotkey.on_hotkey_released                               -- 热键释放回调
```

### [悬停](components/base/hover_api.md)

查看 [API](components/base/hover_api.md)

```lua
local hover = self.druid:new_hover(node, [on_hover_callback], [on_mouse_hover_callback])

hover:is_enabled()                           -- 检查悬停是否启用
hover:is_hovered()                           -- 检查是否被悬停
hover:is_mouse_hovered()                     -- 检查鼠标是否悬停
hover:set_click_zone([zone])                 -- 设置点击区域
hover:set_enabled([state])                   -- 设置启用状态
hover:set_hover([state])                     -- 设置悬停状态
hover:set_mouse_hover([state])               -- 设置鼠标悬停状态

hover.on_hover                               -- 悬停回调
hover.on_mouse_hover                         -- 鼠标悬停回调
```

### [输入](components/extended/input_api.md)

查看 [API](components/extended/input_api.md)

```lua
local input = self.druid:new_input(click_node, text_node, [keyboard_type])

input:get_text()                                           -- 获取文本
input:get_text_selected()                                  -- 获取选中的文本
input:get_text_selected_replaced(text)                     -- 获取替换选中文本后的文本
input:move_selection(delta, is_add_to_selection, is_move_to_end)  -- 移动选择
input:on_focus_lost()                                      -- 失去焦点时的回调
input:reset_changes()                                      -- 重置更改
input:select()                                             -- 全选
input:select_cursor([cursor_index], [start_index], [end_index])  -- 选择光标
input:set_allowed_characters(characters)                   -- 设置允许的字符
input:set_max_length(max_length)                           -- 设置最大长度
input:set_text(input_text)                                 -- 设置文本
input:unselect()                                           -- 取消选择

input.on_input_select                                      -- 输入选择回调
input.on_input_unselect                                    -- 输入取消选择回调
input.on_input_text                                        -- 输入文本回调
input.on_input_empty                                       -- 输入为空回调
input.on_input_full                                        -- 输入满回调
input.on_input_wrong                                       -- 输入错误回调
input.on_select_cursor_change                              -- 选择光标改变回调
```

### [语言文本](components/extended/lang_text_api.md)

查看 [API](components/extended/lang_text_api.md)

```lua
local lang_text = self.druid:new_lang_text(node, [locale_id], [adjust_type])

lang_text:format([a], [b], [c], [d], [e], [f], [g])         -- 格式化文本
lang_text:on_language_change()                                -- 语言改变时的回调
lang_text:set_text(text)                                      -- 设置文本
lang_text:set_to(text)                                        -- 设置目标文本
lang_text:translate(locale_id, [a], [b], [c], [d], [e], [f], [g])  -- 翻译文本

lang_text.on_change                                           -- 文本改变回调
```

### [布局](components/extended/layout_api.md)

查看 [API](components/extended/layout_api.md)

```lua
local layout = self.druid:new_layout(node, [mode])

layout:add(node_or_node_id)                                  -- 添加节点
layout:calculate_rows_data()                                 -- 计算行数据
layout:clear_layout()                                        -- 清空布局
layout:get_content_size()                                    -- 获取内容尺寸
layout:get_entities()                                        -- 获取实体
layout:get_entities_count()                                  -- 获取实体数量
layout:get_node_size(node)                                   -- 获取节点尺寸
layout:get_size()                                            -- 获取尺寸
layout:refresh_layout([is_instant])                          -- 刷新布局
layout:remove(node_or_node_id)                               -- 移除节点
layout:set_dirty()                                           -- 设置脏标记
layout:set_hug_content(is_hug_width, is_hug_height)          -- 设置适应内容
layout:set_justify(is_justify)                               -- 设置两端对齐
layout:set_margin([margin_x], [margin_y])                    -- 设置边距
layout:set_node_index([node], [index])                       -- 设置节点索引
layout:set_node_position(node, x, y, [is_instant])           -- 设置节点位置
layout:set_padding([padding_x], [padding_y], [padding_z], [padding_w])  -- 设置内边距
layout:set_position_function(callback)                       -- 设置位置函数
layout:set_type(type)                                        -- 设置类型
layout:update()                                              -- 更新布局

layout.on_size_changed                                       -- 尺寸改变回调
```

### [进度条](components/extended/progress_api.md)

查看 [API](components/extended/progress_api.md)

```lua
local progress = self.druid:new_progress(node, key, [init_value])

progress:empty()                              -- 清空进度
progress:fill()                               -- 填充进度
progress:get()                                -- 获取进度值
progress:set_max_size(max_size)               -- 设置最大尺寸
progress:set_steps(steps, callback)           -- 设置步进
progress:set_to(to)                           -- 设置目标值
progress:to(to, [callback])                   -- 进度过渡到目标值
progress:update([dt])                         -- 更新进度

progress.on_change                            -- 进度改变回调
```

### [富输入](components/custom/rich_input_api.md)

查看 [API](components/custom/rich_input_api.md)

```lua
local rich_input = self.druid:new_rich_input(template, [nodes])

rich_input:get_text()                          -- 获取文本
rich_input:select()                            -- 选择文本
rich_input:set_allowed_characters(characters)  -- 设置允许的字符
rich_input:set_font(font)                      -- 设置字体
rich_input:set_placeholder(placeholder_text)   -- 设置占位符文本
rich_input:set_text(text)                      -- 设置文本
```

### [富文本](components/custom/rich_text_api.md)

查看 [API](components/custom/rich_text_api.md)

```lua
local rich_text = self.druid:new_rich_text(text_node, [value])

rich_text:characters(word)                     -- 按字符分割
rich_text:clear()                              -- 清空文本
rich_text:get_line_metric()                    -- 获取行度量
rich_text:get_text()                           -- 获取文本
rich_text:get_words()                          -- 获取单词
rich_text:set_pivot(pivot)                     -- 设置轴心点
rich_text:set_text([text])                     -- 设置文本
rich_text:set_split_to_characters(value)       -- 设置按字符分割
rich_text:set_width(width)                     -- 设置宽度
rich_text:set_height(height)                   -- 设置高度
rich_text:tagged(tag)                          -- 标记标签
```

### [滚动](components/base/scroll_api.md)

查看 [API](components/base/scroll_api.md)

```lua
local scroll = self.druid:new_scroll(view_node, content_node)

scroll:bind_grid([grid])                                    -- 绑定网格
scroll:bind_layout([layout])                                -- 绑定布局
scroll:get_percent()                                        -- 获取滚动百分比
scroll:get_scroll_size()                                    -- 获取滚动尺寸
scroll:is_inert()                                           -- 检查是否惯性滚动
scroll:is_node_in_view(node)                                -- 检查节点是否在视图中
scroll:scroll_to(point, [is_instant])                       -- 滚动到指定点
scroll:scroll_to_make_node_visible(node, [is_instant])      -- 滚动使节点可见
scroll:scroll_to_index(index, [skip_cb])                    -- 滚动到指定索引
scroll:scroll_to_percent(percent, [is_instant])             -- 滚动到指定百分比
scroll:set_click_zone(node)                                 -- 设置点击区域
scroll:set_extra_stretch_size([stretch_size])               -- 设置额外拉伸尺寸
scroll:set_horizontal_scroll(state)                         -- 设置水平滚动
scroll:set_inert(state)                                     -- 设置惯性
scroll:set_points(points)                                   -- 设置滚动点
scroll:set_size(size, [offset])                             -- 设置尺寸
scroll:set_vertical_scroll(state)                           -- 设置垂直滚动
scroll:set_view_size(size)                                  -- 设置视图尺寸
scroll:update([dt])                                         -- 更新滚动
scroll:update_view_size()                                   -- 更新视图尺寸

scroll.on_scroll                                            -- 滚动回调
scroll.on_scroll_to                                         -- 滚动到回调
scroll.on_point_scroll                                      -- 点滚动回调
```

### [滑块](components/extended/slider_api.md)

查看 [API](components/extended/slider_api.md)

```lua
local slider = self.druid:new_slider(pin_node, end_pos, [callback])

slider:is_enabled()                           -- 检查是否启用
slider:set(value, [is_silent])                -- 设置值
slider:set_end_pos(end_pos)                   -- 设置结束位置
slider:set_enabled(is_enabled)                -- 设置启用状态
slider:set_input_node([input_node])           -- 设置输入节点
slider:set_steps(steps)                       -- 设置步进

slider.on_change_value                        -- 值改变回调
```

### [滑动](components/extended/swipe_api.md)

查看 [API](components/extended/swipe_api.md)

```lua
local swipe = self.druid:new_swipe(node, [on_swipe_callback])

swipe:set_click_zone([zone])                  -- 设置点击区域

swipe.on_swipe                                -- 滑动回调
```

### [文本](components/base/text_api.md)

查看 [API](components/base/text_api.md)

```lua
local text = self.druid:new_text(node, [value], [no_adjust])

text:get_text()                                -- 获取文本
text:get_text_adjust()                         -- 获取文本调整
text:get_text_index_by_width(width)            -- 根据宽度获取文本索引
text:get_text_size([text])                     -- 获取文本尺寸
text:is_multiline()                            -- 检查是否多行
text:set_alpha(alpha)                          -- 设置透明度
text:set_color(color)                          -- 设置颜色
text:set_minimal_scale(minimal_scale)          -- 设置最小缩放
text:set_pivot(pivot)                          -- 设置轴心点
text:set_scale(scale)                          -- 设置缩放
text:set_size(size)                            -- 设置尺寸
text:set_text([new_text])                      -- 设置文本
text:set_text_adjust([adjust_type], [minimal_scale])  -- 设置文本调整
text:set_to(set_to)                            -- 设置目标值

text.on_set_text                               -- 设置文本回调
text.on_update_text_scale                      -- 更新文本缩放回调
text.on_set_pivot                              -- 设置轴心点回调
```

### [计时器](components/extended/timer_api.md)

查看 [API](components/extended/timer_api.md)

```lua
local timer = self.druid:new_timer(node, [seconds_from], [seconds_to], [callback])

timer:set_interval(from, to)                   -- 设置间隔
timer:set_state([is_on])                       -- 设置状态
timer:set_to(set_to)                           -- 设置目标值
timer:update([dt])                             -- 更新计时器

timer.on_tick                                  -- 计时回调
timer.on_set_enabled                           -- 设置启用回调
timer.on_timer_end                             -- 计时结束回调
```

## [助手](druid_helper_api.md)

查看 [API](druid_helper_api.md)

```lua
local helper = require("druid.helper")

helper.add_array([target], [source])                               -- 添加数组
helper.centrate_icon_with_text([icon_node], [text_node], [margin]) -- 居中图标与文本
helper.centrate_nodes([margin], ...)                              -- 居中节点
helper.centrate_text_with_icon([text_node], [icon_node], margin)   -- 居中文本与图标
helper.clamp(value, [v1], [v2])                                  -- 限制数值范围
helper.contains([array], [value])                                  -- 检查数组是否包含值
helper.deepcopy(orig_table)                                        -- 深拷贝表格
helper.distance(x1, y1, x2, y2)                                   -- 计算距离
helper.get_animation_data_from_node(node, atlas_path)              -- 从节点获取动画数据
helper.get_border(node, [offset])                                  -- 获取边界
helper.get_closest_stencil_node(node)                              -- 获取最近的蒙版节点
helper.get_full_position(node, [root])                             -- 获取完整位置
helper.get_gui_scale()                                             -- 获取GUI缩放
helper.get_node(node_id, [template], [nodes])                      -- 获取节点
helper.get_pivot_offset(pivot_or_node)                             -- 获取轴心偏移
helper.get_scaled_size(node)                                       -- 获取缩放后尺寸
helper.get_scene_scale(node, [include_passed_node_scale])          -- 获取场景缩放
helper.get_screen_aspect_koef()                                    -- 获取屏幕宽高比系数
helper.get_text_metrics_from_node(text_node)                       -- 从文本节点获取度量
helper.insert_with_shift(array, [item], [index], [shift_policy])   -- 插入并移动元素
helper.is_mobile()                                                 -- 检查是否移动端
helper.is_multitouch_supported()                                   -- 检查是否支持多点触控
helper.is_web()                                                    -- 检查是否网页端
helper.is_web_mobile()                                             -- 检查是否网页移动端
helper.lerp(a, b, t)                                               -- 线性插值
helper.pick_node(node, x, y, [node_click_area])                    -- 选择节点
helper.remove_with_shift([array], [index], [shift_policy])         -- 删除并移动元素
helper.round(num, [num_decimal_places])                            -- 四舍五入
helper.sign(val)                                                   -- 获取符号
helper.step(current, target, step)                                 -- 步进
helper.table_to_string(t, [depth])                                 -- 表格转字符串
```

## [Druid 颜色](druid_color_api.md)

查看 [API](druid_color_api.md)

```lua
local color = require("druid.color")

color.get_color(color_id)                  -- 获取颜色ID对应的颜色
color.add_palette(palette_data)            -- 添加调色板数据
color.get_palette()                        -- 获取当前调色板
color.set_color(gui_node, color)           -- 设置GUI节点的颜色
color.lerp(t, color1, color2)              -- 线性插值两个颜色
color.hex2rgb(hex)                         -- 将十六进制颜色转换为RGB
color.hex2vector4(hex, [alpha])            -- 将十六进制颜色转换为vector4
color.rgb2hsb(r, g, b, [alpha])           -- 将RGB颜色转换为HSB
color.hsb2rgb(h, s, v, [alpha])           -- 将HSB颜色转换为RGB
color.rgb2hex(red, green, blue)            -- 将RGB颜色转换为十六进制
```
