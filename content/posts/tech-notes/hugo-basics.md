---
title: "Hugo基础入门指南"
date: 2024-09-03T11:00:00+08:00
draft: false
tags: ["Hugo", "静态网站", "教程"]
categories: ["技术笔记"]
summary: "Hugo静态网站生成器的基础使用方法和核心概念"
---

## 什么是Hugo？

Hugo是一个用Go语言编写的静态网站生成器，它能够将Markdown文件转换为完整的静态网站。

## 核心概念

### 1. 项目结构
```
my-hugo-site/
├── archetypes/     # 内容模板
├── assets/         # 需要处理的资源文件
├── content/        # 网站内容
├── data/          # 数据文件
├── layouts/       # 模板文件
├── static/        # 静态资源
├── themes/        # 主题
└── hugo.yaml      # 配置文件
```

### 2. 内容组织
Hugo使用`content/`目录来组织内容：
- 每个Markdown文件代表一个页面
- 目录结构决定URL结构
- Front Matter定义页面元数据

### 3. 模板系统
- `layouts/`目录存放模板文件
- 支持Go模板语法
- 可以覆盖主题模板

## 常用命令

### 创建新站点
```bash
hugo new site my-site
```

### 启动开发服务器
```bash
hugo server -D
```

### 构建静态文件
```bash
hugo
```

### 创建新内容
```bash
hugo new posts/my-post.md
```

## Front Matter示例

```yaml
---
title: "文章标题"
date: 2024-09-03T10:30:00+08:00
draft: false
tags: ["标签1", "标签2"]
categories: ["分类"]
summary: "文章摘要"
---
```

## 主题使用

### 安装主题
```bash
git submodule add https://github.com/theme-repo themes/theme-name
```

### 配置主题
在`hugo.yaml`中设置：
```yaml
theme: ["theme-name"]
```

## 总结

Hugo是一个功能强大且易于使用的静态网站生成器，特别适合个人博客和技术文档。通过合理的目录结构和模板系统，可以快速构建出专业的网站。
