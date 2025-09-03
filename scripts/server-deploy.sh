#!/bin/bash

# 服务器自动部署脚本
# 使用方法：./server-deploy.sh

set -e

# 配置变量
REPO_URL="https://github.com/your-username/wanghan-blog.git"
DEPLOY_DIR="/var/www/html"
BLOG_DIR="/opt/wanghan-blog"
HUGO_VERSION="0.121.2"
LOG_FILE="/var/log/hugo-deploy.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    log "请使用 root 用户运行此脚本"
    exit 1
fi

log "开始部署博客..."

# 1. 更新代码
log "拉取最新代码..."
cd $BLOG_DIR
git pull origin main

# 2. 安装/更新 Hugo
log "检查 Hugo 版本..."
if ! command -v hugo &> /dev/null || [[ $(hugo version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+') != $HUGO_VERSION ]]; then
    log "安装 Hugo $HUGO_VERSION..."
    wget -O hugo.deb "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
    dpkg -i hugo.deb
    rm hugo.deb
fi

# 3. 构建静态网站
log "构建 Hugo 网站..."
hugo --minify --cleanDestinationDir

# 4. 部署到 Web 目录
log "部署到 Web 目录..."
rsync -avz --delete public/ $DEPLOY_DIR/

# 5. 设置权限
log "设置文件权限..."
chown -R www-data:www-data $DEPLOY_DIR
chmod -R 755 $DEPLOY_DIR

# 6. 重启 Web 服务器（如果需要）
if systemctl is-active --quiet nginx; then
    log "重启 Nginx..."
    systemctl reload nginx
elif systemctl is-active --quiet apache2; then
    log "重启 Apache..."
    systemctl reload apache2
fi

log "部署完成！"
