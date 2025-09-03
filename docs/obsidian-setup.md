# Obsidian 博客工作流配置指南

## 1. 安装必要插件

### obsidian-linter 插件
- 插件ID: `platers.obsidian-linter`
- 功能：自动格式化 Markdown 内容
- 配置：启用所有格式化规则

### obsidian-github-publisher 插件
- 插件ID: `obsidian-github-publisher`
- 功能：将文档推送到 GitHub 仓库
- 配置：
  - Repository: `your-username/wanghan-blog`
  - Branch: `main`
  - 启用 PR 模式
  - 设置文件路径映射

## 2. 工作流配置

### 文件结构
```
content/
├── posts/
│   ├── 2024-01-15-my-first-post.md
│   └── 2024-01-16-hugo-setup.md
└── about.md
```

### 文章模板
```markdown
---
title: "文章标题"
date: 2024-01-15T10:00:00+08:00
draft: false
tags: ["标签1", "标签2"]
categories: ["分类"]
description: "文章描述"
---

# 文章标题

文章内容...
```

## 3. 发布流程

1. 在 Obsidian 中创建新文章
2. 使用 obsidian-linter 格式化内容
3. 使用 obsidian-github-publisher 创建 PR
4. 合并 PR 后自动触发服务器部署
