import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.firefox.service import Service as FirefoxService
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.firefox.options import Options as FirefoxOptions
import time


class TestHomePageSimple:
    """简化的首页测试"""
    
    def setup_method(self):
        """设置浏览器驱动"""
        self.driver = None
        self.browser_type = None
        
        # 尝试Chrome
        try:
            chrome_options = Options()
            chrome_options.add_argument('--headless')
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            
            service = Service(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=chrome_options)
            self.browser_type = "Chrome"
            print("✅ 成功启动Chrome浏览器")
        except Exception as e:
            print(f"Chrome启动失败: {e}")
            
            # 尝试Firefox
            try:
                firefox_options = FirefoxOptions()
                firefox_options.add_argument('--headless')
                
                service = FirefoxService(GeckoDriverManager().install())
                self.driver = webdriver.Firefox(service=service, options=firefox_options)
                self.browser_type = "Firefox"
                print("✅ 成功启动Firefox浏览器")
            except Exception as e2:
                print(f"Firefox启动失败: {e2}")
                raise Exception("无法启动任何浏览器")
        
        self.driver.implicitly_wait(10)
        self.wait = WebDriverWait(self.driver, 10)
    
    def teardown_method(self):
        """清理资源"""
        if self.driver:
            self.driver.quit()
    
    def test_home_page_content(self):
        """测试首页内容 - 对应RSpec的测试"""
        print(f"🧪 开始测试，使用浏览器: {self.browser_type}")
        
        # 访问首页 (对应 visit '/')
        self.driver.get("http://localhost:3000/")
        print("📍 已访问 http://localhost:3000/")
        
        # 等待页面加载
        time.sleep(1)
        
        # 检查页面源码是否包含 'Home#top' (对应 expect(page).to have_content('Home#top'))
        page_source = self.driver.page_source
        assert "Home#top" in page_source, f"页面应该包含 'Home#top' 文本，但实际内容是: {page_source[:200]}..."
        
        print("✅ 页面包含 'Home#top' 文本")
        
        # 检查元素是否可见
        try:
            home_element = self.wait.until(
                EC.presence_of_element_located((By.XPATH, "//*[contains(text(), 'Home#top')]"))
            )
            assert home_element.is_displayed(), "Home#top 元素应该可见"
            print("✅ 'Home#top' 元素可见")
        except Exception as e:
            print(f"⚠️ 未找到可见的 'Home#top' 元素: {e}")
            print("页面源码预览:")
            print(page_source[:500])
            raise
        
        print("🎉 测试通过！")


def test_without_class():
    """不使用类的简单测试版本"""
    driver = None
    try:
        # 自动安装并启动Chrome
        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=chrome_options)
        
        # 访问首页
        driver.get("http://localhost:3000/")
        
        # 检查内容
        assert "Home#top" in driver.page_source, "页面应该包含 'Home#top'"
        print("✅ 简单测试通过")
        
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        raise
    finally:
        if driver:
            driver.quit()


if __name__ == "__main__":
    print("🚀 开始运行Python测试...")
    print("注意: 请确保Rails服务器正在运行 (bin/rails server)")
    print("=" * 50)
    
    # 运行测试
    pytest.main([__file__, "-v", "-s"]) 