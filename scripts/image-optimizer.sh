#!/bin/bash

# 图片优化脚本
# 使用方法: ./scripts/image-optimizer.sh [image_path]

IMAGE_PATH=${1:-"static/images"}

echo "🖼️ 开始优化图片..."

# 检查是否安装了ImageMagick
if ! command -v convert &> /dev/null; then
    echo "❌ 请先安装ImageMagick: brew install imagemagick"
    exit 1
fi

# 优化图片
find $IMAGE_PATH -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read file; do
    echo "🔄 优化: $file"
    
    # 获取文件信息
    filename=$(basename "$file")
    dirname=$(dirname "$file")
    name="${filename%.*}"
    ext="${filename##*.}"
    
    # 创建优化后的文件名
    optimized_file="$dirname/${name}_optimized.$ext"
    
    # 优化图片 (压缩质量80%, 最大宽度1200px)
    convert "$file" -quality 80 -resize '1200>' "$optimized_file"
    
    # 如果优化成功，替换原文件
    if [ $? -eq 0 ]; then
        mv "$optimized_file" "$file"
        echo "✅ 优化完成: $file"
    else
        echo "❌ 优化失败: $file"
        rm -f "$optimized_file"
    fi
done

echo "🎉 图片优化完成!"
