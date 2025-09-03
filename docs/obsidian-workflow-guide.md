# Obsidian博客写作工作流指南

## 🎯 工作流概述

这个工作流让你可以在Obsidian中舒适地写博客，然后一键发布到你的个人网站。

## 📋 准备工作

### 1. 安装Obsidian插件

在Obsidian中安装以下插件：

- **Templater**: 模板管理
- **Obsidian Git**: Git集成
- **Paste Image Rename**: 图片重命名
- **Image Toolkit**: 图片预览
- **Advanced URI**: 高级URI支持

### 2. 配置插件

1. **Templater配置**:
   - 模板文件夹: `templates`
   - 启用文件创建时触发
   - 启用系统命令

2. **Obsidian Git配置**:
   - 自动提交间隔: 10分钟
   - 自动推送: 开启
   - 提交信息格式: `更新博客内容 - {date}`

## ✍️ 写作流程

### 1. 创建新文章

**方法一: 使用模板**
1. 按 `Ctrl+Shift+N` 打开模板选择器
2. 选择模板类型：
   - `simple-blog-post.md` - 简单博客文章（推荐）
   - `simple-tech-note.md` - 简单技术笔记（推荐）
   - `smart-blog-post.md` - 智能博客文章（带提示）
   - `smart-tech-note.md` - 智能技术笔记（带提示）
   - `blog-post.md` - 基础博客文章
   - `tech-note.md` - 基础技术笔记
3. 填写文章信息

**方法二: 手动创建**
1. 在 `content/posts/` 下创建新文件
2. 复制模板内容
3. 修改frontmatter

### 2. 文章结构

```markdown
---
title: "文章标题"
date: 2024-01-01T10:00:00+08:00
draft: true  # 草稿状态
tags: ["标签1", "标签2"]
categories: ["分类"]
description: "文章描述"
cover:
  image: "封面图片路径"
  alt: "图片描述"
  caption: "图片说明"
  relative: false
---

# 文章标题

## 概述
...

## 主要内容
...

## 总结
...
```

### 3. 图片处理

1. **插入图片**:
   - 直接拖拽到Obsidian
   - 使用 `Ctrl+V` 粘贴
   - 图片会自动保存到 `static/images/`

2. **优化图片**:
   ```bash
   ./scripts/image-optimizer.sh
   ```

## 🚀 发布流程

### 1. 草稿模式

```bash
./scripts/blog-workflow.sh draft
```
- 启动本地预览服务器
- 包含草稿文章
- 访问: http://localhost:1313

### 2. 发布文章

```bash
./scripts/blog-workflow.sh publish
```
- 自动将草稿改为发布状态
- 确认后批量发布

### 3. 部署到网站

```bash
./scripts/blog-workflow.sh deploy
```
- 构建静态文件
- 提交到Git
- 推送到GitHub
- 自动部署到GitHub Pages

## 🔧 高级功能

### 1. 批量操作

```bash
# 构建博客
./scripts/blog-workflow.sh build

# 优化所有图片
./scripts/image-optimizer.sh

# 查看Git状态
git status
```

### 2. 快捷键

- `Ctrl+Shift+N`: 创建新文章
- `Ctrl+Shift+C`: 提交更改
- `Ctrl+Shift+P`: 推送到远程
- `Ctrl+Shift+L`: 拉取更新

### 3. 自动化

- **Obsidian Git**: 自动提交和推送
- **GitHub Actions**: 自动部署
- **图片优化**: 自动压缩

## 📁 文件结构

```
wanghan-blog/
├── .obsidian/              # Obsidian配置
│   ├── app.json           # 应用设置
│   ├── workspace.json     # 工作区布局
│   ├── hotkeys.json       # 快捷键
│   └── plugins/           # 插件配置
├── templates/             # 文章模板
│   ├── simple-blog-post.md    # 简单博客文章模板（推荐）
│   ├── simple-tech-note.md    # 简单技术笔记模板（推荐）
│   ├── smart-blog-post.md     # 智能博客文章模板（带提示）
│   ├── smart-tech-note.md     # 智能技术笔记模板（带提示）
│   ├── blog-post.md           # 基础博客文章模板
│   └── tech-note.md           # 基础技术笔记模板
├── scripts/              # 自动化脚本
│   ├── blog-workflow.sh  # 博客工作流
│   └── image-optimizer.sh # 图片优化
├── content/posts/        # 博客文章
├── static/images/        # 图片资源
└── .github/workflows/    # GitHub Actions
```

## 🎨 写作技巧

### 1. 使用标签系统

```markdown
tags: ["技术笔记", "Hugo", "Obsidian", "工作流"]
```

### 2. 分类管理

- **技术笔记**: 编程、工具、教程
- **建站日志**: 博客搭建、维护记录
- **杂谈**: 生活感悟、思考

### 3. 图片管理

- 使用描述性文件名
- 添加alt文本
- 适当压缩图片

### 4. SEO优化

- 填写description
- 使用合适的标签
- 添加封面图片

## 🐛 常见问题

### 1. 图片不显示

- 检查图片路径是否正确
- 确认图片已保存到 `static/images/`
- 检查frontmatter中的图片配置

### 2. 文章不显示

- 检查 `draft: false`
- 确认日期格式正确
- 检查文件路径

### 3. 部署失败

- 检查GitHub Actions日志
- 确认GitHub Pages设置
- 检查域名配置

## 📞 技术支持

如果遇到问题，可以：

1. 查看GitHub Actions日志
2. 检查本地Hugo服务器输出
3. 查看Obsidian插件日志
4. 参考Hugo官方文档

---

**祝你写作愉快！** 🎉
