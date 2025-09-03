#!/usr/bin/env python3
"""
GitHub Webhook 服务器
接收 GitHub 推送事件并触发自动部署
"""

import os
import json
import subprocess
import hmac
import hashlib
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

# 配置
WEBHOOK_SECRET = os.getenv('WEBHOOK_SECRET', 'your-webhook-secret')
DEPLOY_SCRIPT = '/opt/wanghan-blog/scripts/server-deploy.sh'
LOG_FILE = '/var/log/webhook-deploy.log'

def log(message):
    """记录日志"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")

def verify_signature(payload, signature):
    """验证 GitHub Webhook 签名"""
    if not signature:
        return False
    
    expected_signature = 'sha256=' + hmac.new(
        WEBHOOK_SECRET.encode('utf-8'),
        payload,
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(signature, expected_signature)

@app.route('/webhook/deploy', methods=['POST'])
def webhook():
    """处理 GitHub Webhook"""
    try:
        # 获取请求数据
        payload = request.get_data()
        signature = request.headers.get('X-Hub-Signature-256')
        
        # 验证签名
        if not verify_signature(payload, signature):
            log("Webhook 签名验证失败")
            return jsonify({'error': 'Invalid signature'}), 401
        
        # 解析 JSON 数据
        data = json.loads(payload)
        event_type = request.headers.get('X-GitHub-Event')
        
        log(f"收到 {event_type} 事件")
        
        # 处理推送事件
        if event_type == 'push' and data.get('ref') == 'refs/heads/main':
            log("检测到 main 分支推送，开始部署...")
            deploy_blog()
            return jsonify({'status': 'success', 'message': 'Deployment triggered'})
        
        # 处理 PR 合并事件
        elif event_type == 'pull_request' and data.get('action') == 'closed':
            pr = data.get('pull_request', {})
            if pr.get('merged') and pr.get('base', {}).get('ref') == 'main':
                log("检测到 PR 合并到 main 分支，开始部署...")
                deploy_blog()
                return jsonify({'status': 'success', 'message': 'Deployment triggered'})
        
        log(f"事件类型 {event_type} 不需要部署")
        return jsonify({'status': 'ignored', 'message': 'Event ignored'})
        
    except Exception as e:
        log(f"处理 Webhook 时出错: {str(e)}")
        return jsonify({'error': str(e)}), 500

def deploy_blog():
    """执行博客部署"""
    try:
        log("开始执行部署脚本...")
        result = subprocess.run(
            ['bash', DEPLOY_SCRIPT],
            capture_output=True,
            text=True,
            timeout=300  # 5分钟超时
        )
        
        if result.returncode == 0:
            log("部署成功完成")
        else:
            log(f"部署失败: {result.stderr}")
            
    except subprocess.TimeoutExpired:
        log("部署超时")
    except Exception as e:
        log(f"部署过程中出错: {str(e)}")

@app.route('/health', methods=['GET'])
def health():
    """健康检查端点"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

if __name__ == '__main__':
    log("启动 Webhook 服务器...")
    app.run(host='0.0.0.0', port=5000, debug=False)
