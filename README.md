# 🌟 BonnieW的个人博客

> 基于 Hugo + PaperMod 主题构建的现代化个人博客网站

[![Hugo](https://img.shields.io/badge/Hugo-0.121.0-blue.svg)](https://gohugo.io/)
[![PaperMod](https://img.shields.io/badge/Theme-PaperMod-green.svg)](https://github.com/adityatelange/hugo-PaperMod)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## ✨ 功能特性

### 🎨 界面设计
- ✅ **响应式设计** - 完美适配桌面端、平板和移动设备
- ✅ **深色/浅色主题** - 自动切换，支持手动切换
- ✅ **现代化UI** - 简洁美观的PaperMod主题
- ✅ **打字机效果** - 首页标题动态打字效果
- ✅ **自定义首页** - 个人网站风格的首页布局

### 🔍 内容管理
- ✅ **智能搜索** - 支持标题、内容、标签全文搜索
- ✅ **分类标签** - 多维度内容分类管理
- ✅ **归档页面** - 按时间线展示所有文章
- ✅ **目录导航** - 文章内自动生成目录
- ✅ **代码高亮** - 支持多种编程语言语法高亮
- ✅ **数学公式** - 支持LaTeX数学公式渲染

### 📊 数据统计
- ✅ **访问量统计** - 集成不蒜子访问量统计
- ✅ **文章阅读量** - 单篇文章阅读次数统计
- ✅ **RSS订阅** - 支持RSS/Atom订阅

### 🌐 社交功能
- ✅ **评论系统** - 集成Giscus GitHub评论
- ✅ **社交媒体** - GitHub、邮箱等社交链接
- ✅ **分享功能** - 文章分享到社交媒体

## 🚀 快速开始

### 📋 环境要求

- **Hugo**: 0.121.0 或更高版本
- **Git**: 用于版本控制
- **Node.js**: 用于资源优化（可选）

### 🛠️ 本地开发

```bash
# 克隆仓库
git clone https://github.com/BonnieW05/wanghan-blog.git
cd wanghan-blog

# 启动开发服务器（包含草稿）
hugo server --buildDrafts --buildFuture --bind="0.0.0.0" --port=1313

# 或者使用便捷脚本
./scripts/blog-workflow.sh draft
```

访问 [http://localhost:1313](http://localhost:1313) 查看本地预览。

### 📝 写作工作流

#### 方法一：使用脚本（推荐）

```bash
# 启动草稿模式
./scripts/blog-workflow.sh draft

# 发布文章（将草稿状态改为false）
./scripts/blog-workflow.sh publish

# 构建并部署
./scripts/blog-workflow.sh deploy
```

#### 方法二：使用Obsidian（高级用户）

1. **安装插件**：
   - Templater - 模板管理
   - Obsidian Git - Git集成
   - Paste Image Rename - 图片重命名

2. **配置工作流**：
   - 使用模板创建新文章
   - 自动图片处理和重命名
   - 一键发布到GitHub

详细配置请参考：[Obsidian工作流指南](docs/obsidian-workflow-guide.md)

### 🌐 部署到服务器

```bash
# 部署到指定服务器
./deploy.sh your_server_ip

# 例如部署到阿里云服务器
./deploy.sh 123.456.789.123
```

## 📁 项目结构

```
wanghan-blog/
├── 📁 content/              # 博客内容
│   ├── 📁 posts/           # 文章目录
│   │   ├── 📁 学习笔记/    # 学习笔记分类
│   │   ├── 📁 技术笔记/    # 技术笔记分类
│   │   ├── 📁 建站日志/    # 建站日志分类
│   │   └── 📁 杂谈/        # 杂谈分类
│   ├── 📁 categories/      # 分类页面
│   ├── 📄 about.md         # 关于页面
│   ├── 📄 archive.md       # 归档页面
│   └── 📄 search.md        # 搜索页面
├── 📁 layouts/             # 自定义模板
│   ├── 📁 _default/        # 默认模板
│   ├── 📁 partials/        # 部分模板
│   └── 📄 index.html       # 自定义首页
├── 📁 static/              # 静态资源
│   ├── 📁 css/             # 自定义样式
│   ├── 📁 js/              # 自定义脚本
│   └── 📁 images/          # 图片资源
├── 📁 themes/              # 主题文件
│   └── 📁 PaperMod/        # PaperMod主题
├── 📁 scripts/             # 脚本文件
│   ├── 📄 blog-workflow.sh # 博客工作流脚本
│   ├── 📄 image-optimizer.sh # 图片优化脚本
│   └── 📄 deploy.sh        # 部署脚本
├── 📁 templates/           # Obsidian模板
├── 📁 docs/                # 文档
├── 📄 hugo.yaml           # Hugo配置文件
└── 📄 README.md           # 项目说明
```

## ⚙️ 配置说明

### 🔧 主要配置文件

- **`hugo.yaml`** - Hugo主配置文件
- **`layouts/`** - 自定义模板和布局
- **`static/`** - 静态资源文件
- **`themes/PaperMod/`** - 主题配置

### 🎨 主题定制

```yaml
# hugo.yaml 中的主要配置
params:
  title: "BonnieW的个人博客"
  description: "欢迎来到我的个人博客"
  author: "BonnieW"
  
  # 主题配置
  themeVariant: auto
  defaultTheme: auto
  
  # 功能开关
  ShowReadingTime: true
  ShowShareButtons: false
  ShowPostNavLinks: true
  ShowBreadCrumbs: true
  ShowCodeCopyButtons: true
  ShowWordCount: true
  UseHugoToc: true
  
  # 数学公式
  math:
    enable: true
    mathjax:
      enable: true
```

### 🖼️ 图片处理

```bash
# 优化图片
./scripts/image-optimizer.sh

# 图片会自动保存到 static/images/ 目录
# 在文章中引用：![描述](/images/图片名.jpg)
```

## 📚 使用指南

### 📝 创建新文章

1. **使用模板**：
   ```bash
   # 复制模板
   cp templates/blog-post.md content/posts/新文章.md
   
   # 编辑文章内容
   vim content/posts/新文章.md
   ```

2. **文章结构**：
   ```markdown
   ---
   title: "文章标题"
   date: 2024-12-19T10:00:00+08:00
   draft: false
   tags: ["标签1", "标签2"]
   categories: ["分类"]
   description: "文章描述"
   cover:
     image: "封面图片路径"
     alt: "图片描述"
   ---
   
   # 文章内容
   ```

### 🏷️ 分类和标签

- **分类**：在 `content/categories/` 下创建分类页面
- **标签**：在文章frontmatter中添加tags
- **归档**：自动按时间生成归档页面

### 🔍 搜索功能

- 支持标题、内容、标签全文搜索
- 搜索结果高亮显示
- 支持模糊匹配

## 🛠️ 开发工具

### 📦 推荐工具

- **编辑器**：VS Code + Hugo扩展
- **写作**：Obsidian + 相关插件
- **图片处理**：TinyPNG、ImageOptim
- **版本控制**：Git + GitHub

### 🔧 开发脚本

```bash
# 博客工作流
./scripts/blog-workflow.sh [draft|publish|deploy|build]

# 图片优化
./scripts/image-optimizer.sh

# 服务器部署
./deploy.sh [server_ip]
```

## 🌟 特色功能

### 🎯 智能搜索
- 全文搜索支持
- 搜索结果高亮
- 模糊匹配算法

### 📊 数据统计
- 实时访问量统计
- 文章阅读量追踪
- 用户行为分析

### 🎨 主题定制
- 深色/浅色主题切换
- 自定义CSS样式
- 响应式设计

### 📱 移动端优化
- 完美移动端适配
- 触摸友好的交互
- 快速加载优化

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- **GitHub**: [@BonnieW05](https://github.com/BonnieW05)
- **邮箱**: bonniewang0511@gmail.com
- **博客**: [8fwh.cn](https://8fwh.cn)

## 🙏 致谢

- [Hugo](https://gohugo.io/) - 静态网站生成器
- [PaperMod](https://github.com/adityatelange/hugo-PaperMod) - 优秀的Hugo主题
- [Giscus](https://giscus.app/) - GitHub评论系统
- [不蒜子](https://busuanzi.ibruce.info/) - 访问量统计

---

⭐ 如果这个项目对你有帮助，请给个Star支持一下！