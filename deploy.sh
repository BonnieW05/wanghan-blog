#!/bin/bash

# 博客部署脚本
# 使用方法: ./deploy.sh [server_ip]

# 设置默认参数
SERVER_IP=${1:-"localhost"}
BASE_URL="http://${SERVER_IP}:1313"

echo "🚀 开始部署博客到 ${BASE_URL}"

# 停止可能正在运行的 Hugo 服务器
echo "📋 停止现有服务器..."
pkill -f "hugo server" || true

# 启动 Hugo 服务器
echo "🌐 启动 Hugo 服务器..."
hugo server --bind="0.0.0.0" --baseURL="${BASE_URL}" --port=1313 --buildDrafts=false --buildFuture=false

echo "✅ 博客已部署完成！"
echo "🔗 访问地址: ${BASE_URL}"
echo "📱 本地访问: http://localhost:1313"
