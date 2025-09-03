#!/bin/bash

# 服务器环境配置脚本
# 在阿里云服务器上运行此脚本来设置博客环境

set -e

# 配置变量
REPO_URL="https://github.com/your-username/wanghan-blog.git"
BLOG_DIR="/opt/wanghan-blog"
DEPLOY_DIR="/var/www/html"
HUGO_VERSION="0.121.2"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    error "请使用 root 用户运行此脚本"
fi

log "开始配置服务器环境..."

# 1. 更新系统
log "更新系统包..."
apt update && apt upgrade -y

# 2. 安装必要软件
log "安装必要软件..."
apt install -y git curl wget nginx python3 python3-pip rsync

# 3. 安装 Hugo
log "安装 Hugo $HUGO_VERSION..."
wget -O hugo.deb "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb"
dpkg -i hugo.deb
rm hugo.deb

# 4. 克隆博客仓库
log "克隆博客仓库..."
if [ -d "$BLOG_DIR" ]; then
    warning "博客目录已存在，跳过克隆"
else
    git clone $REPO_URL $BLOG_DIR
fi

# 5. 设置目录权限
log "设置目录权限..."
chown -R www-data:www-data $BLOG_DIR
chmod -R 755 $BLOG_DIR

# 6. 配置 Nginx
log "配置 Nginx..."
cat > /etc/nginx/sites-available/blog << EOF
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root $DEPLOY_DIR;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # 静态文件缓存
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试 Nginx 配置
nginx -t

# 启动 Nginx
systemctl enable nginx
systemctl start nginx

# 7. 安装 Python 依赖
log "安装 Python 依赖..."
pip3 install flask

# 8. 创建 systemd 服务
log "创建 Webhook 服务..."
cat > /etc/systemd/system/blog-webhook.service << EOF
[Unit]
Description=Blog Webhook Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$BLOG_DIR
ExecStart=/usr/bin/python3 $BLOG_DIR/scripts/webhook-server.py
Restart=always
RestartSec=10
Environment=WEBHOOK_SECRET=your-webhook-secret

[Install]
WantedBy=multi-user.target
EOF

# 9. 设置定时任务（可选：定期拉取更新）
log "设置定时任务..."
cat > /etc/cron.d/blog-sync << EOF
# 每小时检查一次更新
0 * * * * root cd $BLOG_DIR && git fetch && git log HEAD..origin/main --oneline | wc -l | grep -q '^0$' || $BLOG_DIR/scripts/server-deploy.sh
EOF

# 10. 创建日志目录
log "创建日志目录..."
mkdir -p /var/log
touch /var/log/hugo-deploy.log
touch /var/log/webhook-deploy.log
chown www-data:www-data /var/log/hugo-deploy.log /var/log/webhook-deploy.log

# 11. 首次部署
log "执行首次部署..."
cd $BLOG_DIR
bash scripts/server-deploy.sh

# 12. 启动 Webhook 服务
log "启动 Webhook 服务..."
systemctl daemon-reload
systemctl enable blog-webhook
systemctl start blog-webhook

log "服务器配置完成！"
log "请记得："
log "1. 修改 /etc/nginx/sites-available/blog 中的域名"
log "2. 设置 GitHub Webhook: http://your-server-ip:5000/webhook/deploy"
log "3. 在 GitHub 仓库设置中添加 DEPLOY_TOKEN secret"
log "4. 修改脚本中的仓库 URL 和配置"

echo -e "${GREEN}配置完成！你的博客现在可以通过 http://your-server-ip 访问了${NC}"
