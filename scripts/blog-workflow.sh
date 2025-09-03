#!/bin/bash

# Obsidian博客工作流脚本
# 使用方法: ./scripts/blog-workflow.sh [action]
# action: draft, publish, deploy

ACTION=${1:-"draft"}
BLOG_DIR="/Users/wanghan/coding/wanghan-blog"

echo "🚀 开始博客工作流: $ACTION"

case $ACTION in
  "draft")
    echo "📝 启动草稿模式..."
    cd $BLOG_DIR
    hugo server --buildDrafts --buildFuture --bind="0.0.0.0" --port=1313
    ;;
    
  "publish")
    echo "📤 发布文章..."
    cd $BLOG_DIR
    
    # 查找所有草稿文章
    DRAFT_FILES=$(find content/posts -name "*.md" -exec grep -l "draft: true" {} \;)
    
    if [ -z "$DRAFT_FILES" ]; then
      echo "✅ 没有找到草稿文章"
    else
      echo "📋 找到以下草稿文章:"
      echo "$DRAFT_FILES"
      
      read -p "是否要发布这些文章? (y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 将草稿状态改为false
        for file in $DRAFT_FILES; do
          sed -i '' 's/draft: true/draft: false/g' "$file"
          echo "✅ 已发布: $file"
        done
      fi
    fi
    ;;
    
  "deploy")
    echo "🌐 部署博客..."
    cd $BLOG_DIR
    
    # 构建静态文件
    echo "🔨 构建静态文件..."
    hugo --minify
    
    # 提交到Git
    echo "📝 提交到Git..."
    git add .
    git commit -m "更新博客内容 - $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    
    echo "✅ 博客已部署完成!"
    ;;
    
  "build")
    echo "🔨 构建博客..."
    cd $BLOG_DIR
    hugo --minify
    echo "✅ 构建完成!"
    ;;
    
  *)
    echo "❌ 未知操作: $ACTION"
    echo "可用操作: draft, publish, deploy, build"
    exit 1
    ;;
esac
