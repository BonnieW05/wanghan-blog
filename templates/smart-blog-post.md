---
title: "<% tp.user.prompt("请输入文章标题") %>"
date: <% tp.date.now("YYYY-MM-DDTHH:mm:ss+08:00") %>
draft: true
tags: [<% tp.user.prompt("请输入标签，用逗号分隔", "技术, 教程") %>]
categories: [<% tp.user.prompt("请输入分类", "技术笔记") %>]
description: "<% tp.user.prompt("请输入文章描述") %>"
cover:
  image: ""
  alt: ""
  caption: ""
  relative: false
---

# <% tp.user.prompt("请输入文章标题") %>

## 概述

在这里写文章概述...

## 主要内容

### 章节1

内容...

### 章节2

内容...

## 总结

总结内容...

---

**标签**: #<% tp.user.prompt("请输入标签，用逗号分隔", "技术, 教程").replace(/,/g, " #") %>
**分类**: <% tp.user.prompt("请输入分类", "技术笔记") %>
**创建时间**: <% tp.date.now("YYYY-MM-DD HH:mm") %>
**更新时间**: <% tp.date.now("YYYY-MM-DD HH:mm") %>
