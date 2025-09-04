#!/bin/bash

# 域名配置测试脚本
# 使用方法: ./scripts/domain-test.sh

echo "🔍 开始测试域名配置..."

# 测试本地Hugo构建
echo "📦 测试Hugo构建..."
hugo --gc --minify

if [ $? -eq 0 ]; then
    echo "✅ Hugo构建成功"
else
    echo "❌ Hugo构建失败"
    exit 1
fi

# 检查配置文件
echo "🔧 检查配置文件..."

# 检查baseURL
BASE_URL=$(grep "baseURL:" hugo.yaml | cut -d' ' -f2)
echo "📍 当前baseURL: $BASE_URL"

if [[ "$BASE_URL" == "https://8fwh.cn/" ]]; then
    echo "✅ baseURL配置正确"
else
    echo "❌ baseURL配置错误，应该是: https://8fwh.cn/"
fi

# 检查CNAME
CNAME_DOMAIN=$(cat CNAME)
echo "🌐 当前CNAME: $CNAME_DOMAIN"

if [[ "$CNAME_DOMAIN" == "8fwh.cn" ]]; then
    echo "✅ CNAME配置正确"
else
    echo "❌ CNAME配置错误，应该是: 8fwh.cn"
fi

echo ""
echo "🎉 配置检查完成！"
echo "📋 下一步操作："
echo "1. 提交代码到GitHub: git add . && git commit -m '配置GitHub Pages自定义域名8fwh.cn' && git push"
echo "2. 在GitHub仓库设置中启用Pages"
echo "3. 在阿里云DNS中添加CNAME记录指向GitHub Pages"
echo "4. 在GitHub Pages设置中添加自定义域名8fwh.cn"
