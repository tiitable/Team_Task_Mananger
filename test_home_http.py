import requests
import pytest
import time
import os

# 禁用代理设置
os.environ['HTTP_PROXY'] = ''
os.environ['HTTPS_PROXY'] = ''
os.environ['http_proxy'] = ''
os.environ['https_proxy'] = ''


class TestHomePageHTTP:
    """使用HTTP请求测试首页功能"""
    
    def setup_method(self):
        """设置测试环境"""
        self.base_url = "http://localhost:3000"
        # 创建session并禁用代理
        self.session = requests.Session()
        self.session.proxies = {
            'http': None,
            'https': None
        }
    
    def test_home_page_content(self):
        """测试首页内容 - 对应RSpec的测试"""
        print("🧪 开始HTTP测试...")
        
        # 访问首页 (对应 visit '/')
        response = self.session.get(f"{self.base_url}/")
        print(f"📍 已访问 {self.base_url}/")
        print(f"📊 状态码: {response.status_code}")
        
        # 检查响应状态
        assert response.status_code == 200, f"页面应该返回200状态码，但实际是{response.status_code}"
        print("✅ 页面返回200状态码")
        
        # 检查页面源码是否包含 'Home#top' (对应 expect(page).to have_content('Home#top'))
        content = response.text
        assert "Home#top" in content, f"页面应该包含 'Home#top' 文本，但实际内容是: {content[:200]}..."
        
        print("✅ 页面包含 'Home#top' 文本")
        
        # 检查HTML结构
        assert "<html>" in content, "页面应该有HTML结构"
        assert "<body>" in content, "页面应该有body标签"
        assert "<h1" in content, "页面应该有h1标签"
        
        print("✅ HTML结构正确")
        print("🎉 HTTP测试通过！")
    
    def test_home_page_headers(self):
        """测试响应头"""
        response = self.session.get(f"{self.base_url}/")
        
        # 检查内容类型
        assert "text/html" in response.headers.get("content-type", ""), "响应应该是HTML内容"
        print("✅ 响应头正确")
    
    def test_home_page_title(self):
        """测试页面标题"""
        response = self.session.get(f"{self.base_url}/")
        content = response.text
        
        # 检查页面标题
        assert "<title>" in content, "页面应该有title标签"
        assert "Team Task Manager" in content, "页面标题应该包含 'Team Task Manager'"
        print("✅ 页面标题正确")


def test_simple_http():
    """简单的HTTP测试函数"""
    print("🚀 开始简单HTTP测试...")
    
    try:
        # 禁用代理设置
        proxies = {
            'http': None,
            'https': None
        }
        
        # 发送GET请求到首页
        response = requests.get("http://localhost:3000/", timeout=10, proxies=proxies)
        
        # 检查状态码
        assert response.status_code == 200, f"状态码应该是200，但实际是{response.status_code}"
        
        # 检查内容
        assert "Home#top" in response.text, "页面应该包含 'Home#top'"
        
        print("✅ 简单HTTP测试通过")
        return True
        
    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到服务器，请确保Rails服务器正在运行")
        return False
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        return False


def test_server_health():
    """测试服务器健康状态"""
    print("🏥 检查服务器健康状态...")
    
    try:
        # 禁用代理设置
        proxies = {
            'http': None,
            'https': None
        }
        
        # 测试连接
        response = requests.get("http://localhost:3000/", timeout=5, proxies=proxies)
        
        if response.status_code == 200:
            print("✅ 服务器运行正常")
            return True
        else:
            print(f"⚠️ 服务器返回状态码: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ 无法连接到服务器")
        return False
    except Exception as e:
        print(f"❌ 健康检查失败: {e}")
        return False


if __name__ == "__main__":
    print("🚀 开始运行HTTP测试...")
    print("注意: 请确保Rails服务器正在运行 (bin/rails server)")
    print("=" * 50)
    
    # 先检查服务器健康状态
    if test_server_health():
        # 运行简单测试
        test_simple_http()
        
        # 运行完整测试
        print("\n" + "=" * 50)
        print("运行完整测试套件...")
        pytest.main([__file__, "-v", "-s"])
    else:
        print("❌ 服务器未运行，请先启动Rails服务器")
        print("运行命令: bin/rails server") 