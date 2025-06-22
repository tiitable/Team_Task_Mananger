#!/usr/bin/env python3
"""
简单的HTTP测试 - 使用urllib库，避免代理问题
对应RSpec测试: expect(page).to have_content('Home#top')
"""

import urllib.request
import urllib.error
import sys


def test_home_page():
    """测试首页内容"""
    print("🧪 开始简单HTTP测试...")
    
    try:
        # 创建请求
        url = "http://localhost:3001/"
        req = urllib.request.Request(url)
        
        # 发送请求
        with urllib.request.urlopen(req, timeout=10) as response:
            # 检查状态码
            status_code = response.getcode()
            print(f"📊 状态码: {status_code}")
            
            if status_code != 200:
                print(f"❌ 状态码应该是200，但实际是{status_code}")
                return False
            
            # 读取内容
            content = response.read().decode('utf-8')
            print(f"📄 页面大小: {len(content)} 字符")
            
            # 检查是否包含 'Home#top'
            if "Home#top" in content:
                print("✅ 页面包含 'Home#top' 文本")
                print("🎉 测试通过！")
                return True
            else:
                print("❌ 页面不包含 'Home#top' 文本")
                print("页面内容预览:")
                print(content[:500])
                return False
                
    except urllib.error.URLError as e:
        print(f"❌ 连接错误: {e}")
        print("请确保Rails服务器正在运行: bin/rails server -p 3001")
        return False
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        return False


def test_server_health():
    """检查服务器健康状态"""
    print("🏥 检查服务器健康状态...")
    
    try:
        url = "http://localhost:3001/"
        req = urllib.request.Request(url)
        
        with urllib.request.urlopen(req, timeout=5) as response:
            if response.getcode() == 200:
                print("✅ 服务器运行正常")
                return True
            else:
                print(f"⚠️ 服务器返回状态码: {response.getcode()}")
                return False
                
    except urllib.error.URLError as e:
        print(f"❌ 无法连接到服务器: {e}")
        return False
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")
        return False


if __name__ == "__main__":
    print("🚀 开始运行简单HTTP测试...")
    print("注意: 请确保Rails服务器正在运行 (bin/rails server -p 3001)")
    print("=" * 50)
    
    # 检查服务器健康状态
    if test_server_health():
        # 运行测试
        success = test_home_page()
        if success:
            print("\n🎉 所有测试通过！")
            sys.exit(0)
        else:
            print("\n❌ 测试失败")
            sys.exit(1)
    else:
        print("\n❌ 服务器未运行，请先启动Rails服务器")
        print("运行命令: bin/rails server -p 3001")
        sys.exit(1) 