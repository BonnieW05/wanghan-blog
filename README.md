# 王涵的个人博客

基于 Hugo + PaperMod 主题构建的个人博客网站。

## 功能特性

- ✅ 响应式设计，支持移动端
- ✅ 搜索功能（支持标题、内容、标签搜索）
- ✅ 归档页面（按时间线展示文章）
- ✅ 标签分类
- ✅ 访问量统计（不蒜子）
- ✅ 文章阅读量统计
- ✅ 代码高亮
- ✅ 目录导航
- ✅ 社交媒体链接
- ✅ RSS 订阅
- ✅ 自定义首页布局（类似个人网站风格）
- ✅ 深色/浅色主题切换
- ✅ 打字机效果
- ✅ 分类按钮导航

## 快速开始

### 本地开发

```bash
# 启动开发服务器
hugo server --bind="0.0.0.0" --baseURL="http://localhost:1313" --port=1313

# 或者使用部署脚本
./deploy.sh
```

### 部署到服务器

```bash
# 部署到指定服务器
./deploy.sh your_server_ip

# 例如部署到阿里云服务器
./deploy.sh 123.456.789.123
```

## 博客工作流

1. **编辑内容**：使用 Obsidian 编辑博客内容
2. **格式化**：使用 obsidian-linter 插件格式化内容
3. **发布**：使用 obsidian-github-publisher 插件通过 PR 合并到仓库
4. **部署**：在服务器上拉取内容并使用 Hugo 生成静态网站

## 目录结构

```
wanghan-blog/
├── content/           # 博客内容
│   ├── posts/        # 文章目录
│   ├── categories/   # 分类页面
│   │   ├── 建站日志/
│   │   ├── 技术笔记/
│   │   └── 杂谈/
│   ├── about.md      # 关于页面
│   ├── archive.md    # 归档页面
│   └── search.md     # 搜索页面
├── layouts/          # 自定义模板
│   └── index.html    # 自定义首页布局
├── static/           # 静态资源
│   ├── css/          # 自定义样式
│   ├── js/           # 自定义脚本
│   └── images/       # 图片资源
├── themes/           # 主题文件
├── hugo.yaml         # 配置文件
└── deploy.sh         # 部署脚本
```

## 配置说明

主要配置文件为 `hugo.yaml`，包含：

- 网站基本信息
- 菜单配置
- 主题参数
- 搜索配置
- 访问量统计配置

## 自定义功能

### 访问量统计

使用不蒜子统计网站和文章访问量，配置在 `hugo.yaml` 中：

```yaml
params:
  busuanzi:
    enable: true
```

### 搜索功能

支持全文搜索，配置在 `content/search.md` 和 `hugo.yaml` 中。

### 归档功能

按时间线展示所有文章，配置在 `content/archive.md` 中。

## 技术栈

- **静态网站生成器**：Hugo
- **主题**：PaperMod
- **访问统计**：不蒜子
- **部署**：Hugo Server

## 联系方式

- 📧 邮箱：bonniewang0511@gmail.com
- 🐙 GitHub：[BonnieW05](https://github.com/BonnieW05)
- 📝 知乎：[bonnie-19-50](https://www.zhihu.com/people/bonnie-19-50)

## 许可证

MIT License
