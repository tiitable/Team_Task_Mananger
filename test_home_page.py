import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.firefox.options import Options as FirefoxOptions
import time


class TestHomePage:
    """测试首页功能"""
    
    def setup_method(self):
        """每个测试方法前的设置"""
        # 尝试使用Chrome
        try:
            chrome_options = Options()
            chrome_options.add_argument('--headless')  # 无头模式
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument('--window-size=1920,1080')
            
            self.driver = webdriver.Chrome(options=chrome_options)
            self.browser_type = "Chrome"
        except Exception as e:
            print(f"Chrome启动失败: {e}")
            # 尝试使用Firefox
            try:
                firefox_options = FirefoxOptions()
                firefox_options.add_argument('--headless')
                
                self.driver = webdriver.Firefox(options=firefox_options)
                self.browser_type = "Firefox"
            except Exception as e2:
                print(f"Firefox启动失败: {e2}")
                raise Exception("无法启动任何浏览器")
        
        self.driver.implicitly_wait(10)
        self.wait = WebDriverWait(self.driver, 10)
    
    def teardown_method(self):
        """每个测试方法后的清理"""
        if hasattr(self, 'driver'):
            self.driver.quit()
    
    def test_home_page_content(self):
        """测试首页是否显示正确的内容"""
        print(f"使用浏览器: {self.browser_type}")
        
        # 访问首页
        self.driver.get("http://localhost:3000/")
        
        # 等待页面加载
        time.sleep(2)
        
        # 检查页面标题
        assert "Home#top" in self.driver.page_source, "页面应该包含 'Home#top' 文本"
        
        # 检查特定元素是否存在
        try:
            home_element = self.wait.until(
                EC.presence_of_element_located((By.XPATH, "//*[contains(text(), 'Home#top')]"))
            )
            assert home_element.is_displayed(), "Home#top 元素应该可见"
        except Exception as e:
            print(f"未找到 'Home#top' 元素: {e}")
            # 打印页面源码以便调试
            print("页面源码:")
            print(self.driver.page_source[:1000])  # 只打印前1000个字符
            raise
        
        print("✅ 首页内容测试通过")
    
    def test_home_page_title(self):
        """测试页面标题"""
        self.driver.get("http://localhost:3000/")
        
        # 检查页面标题
        title = self.driver.title
        print(f"页面标题: {title}")
        
        # 这里可以根据实际页面标题进行调整
        assert title, "页面应该有标题"
    
    def test_home_page_structure(self):
        """测试页面结构"""
        self.driver.get("http://localhost:3000/")
        
        # 检查是否有基本的HTML结构
        assert self.driver.find_element(By.TAG_NAME, "html"), "页面应该有html标签"
        assert self.driver.find_element(By.TAG_NAME, "body"), "页面应该有body标签"
        
        print("✅ 页面结构测试通过")


if __name__ == "__main__":
    # 直接运行测试
    pytest.main([__file__, "-v"]) 