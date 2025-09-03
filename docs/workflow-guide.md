# Obsidian + GitHub + 服务器博客工作流配置指南

## 🎯 工作流程概述

```
Obsidian 编辑 → obsidian-linter 格式化 → obsidian-github-publisher 推送 → GitHub PR → 服务器自动部署 → Hugo 生成网站
```

## 📝 第一步：Obsidian 配置

### 1. 安装插件
- **obsidian-linter**: 自动格式化 Markdown
- **obsidian-github-publisher**: 推送到 GitHub

### 2. 配置 obsidian-github-publisher
```json
{
  "repo": "your-username/wanghan-blog",
  "branch": "main",
  "pr": true,
  "path": "content/posts/",
  "file": "{{title}}.md"
}
```

### 3. 文章模板
在 Obsidian 中创建模板：
```markdown
---
title: "{{title}}"
date: {{date:YYYY-MM-DDTHH:mm:ss+08:00}}
draft: false
tags: ["技术", "博客"]
categories: ["技术分享"]
description: "{{title}}"
---

# {{title}}

文章内容...
```

## 🖥️ 第二步：服务器配置

### 1. 在阿里云服务器上运行配置脚本
```bash
# 下载并运行配置脚本
wget https://raw.githubusercontent.com/your-username/wanghan-blog/main/scripts/setup-server.sh
chmod +x setup-server.sh
sudo ./setup-server.sh
```

### 2. 配置 GitHub Webhook
1. 进入 GitHub 仓库设置
2. 添加 Webhook：
   - URL: `http://your-server-ip:5000/webhook/deploy`
   - Content type: `application/json`
   - Secret: `your-webhook-secret`
   - Events: `Push events` 和 `Pull request events`

### 3. 设置 GitHub Secrets
在仓库设置中添加：
- `DEPLOY_TOKEN`: 用于认证的令牌

## 🔄 第三步：工作流测试

### 1. 创建测试文章
在 Obsidian 中创建一篇测试文章，使用 obsidian-github-publisher 推送。

### 2. 检查部署状态
```bash
# 查看部署日志
tail -f /var/log/hugo-deploy.log

# 查看 Webhook 日志
tail -f /var/log/webhook-deploy.log

# 检查服务状态
systemctl status blog-webhook
systemctl status nginx
```

## 🛠️ 故障排除

### 常见问题

1. **Webhook 不触发部署**
   - 检查 GitHub Webhook 配置
   - 查看服务器防火墙设置
   - 检查 Webhook 服务状态

2. **部署失败**
   - 检查 Git 权限
   - 查看 Hugo 版本
   - 检查文件权限

3. **网站无法访问**
   - 检查 Nginx 配置
   - 查看端口是否开放
   - 检查域名解析

### 调试命令
```bash
# 手动触发部署
cd /opt/wanghan-blog
bash scripts/server-deploy.sh

# 测试 Webhook
curl -X POST http://localhost:5000/health

# 查看服务日志
journalctl -u blog-webhook -f
```

## 📊 监控和维护

### 1. 日志监控
- 部署日志：`/var/log/hugo-deploy.log`
- Webhook 日志：`/var/log/webhook-deploy.log`
- Nginx 日志：`/var/log/nginx/`

### 2. 定期维护
- 更新 Hugo 版本
- 清理旧日志文件
- 备份重要配置

### 3. 性能优化
- 启用 Nginx 缓存
- 配置 CDN
- 优化图片大小

## 🎉 完成！

现在你的博客工作流已经完全配置好了！每次在 Obsidian 中编辑文章并推送，都会自动触发服务器部署，让你的博客保持最新状态。
