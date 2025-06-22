# Python 测试说明

这个目录包含了用Python重写的Rails测试，用于测试首页功能。

## 文件说明

- `test_home_page.py` - 完整的测试类，包含多个测试方法
- `test_home_simple.py` - 简化版本，更容易运行
- `requirements.txt` - Python依赖包列表

## 安装依赖

```bash
# 安装Python依赖
pip install -r requirements.txt
```

## 运行测试

### 1. 启动Rails服务器

```bash
# 在Rails项目目录下启动服务器
bin/rails server
```

### 2. 运行Python测试

```bash
# 运行简化版本测试
python test_home_simple.py

# 或者使用pytest运行
pytest test_home_simple.py -v -s

# 运行完整版本测试
pytest test_home_page.py -v -s
```

## 测试对比

### RSpec版本 (Ruby)
```ruby
require 'rails_helper'
RSpec.describe 'Home', type: :system do
  describe 'top page check' do
    it 'show words of Home#top' do
      visit '/'
      expect(page).to have_content('Home#top')
    end
  end
end
```

### Python版本
```python
def test_home_page_content(self):
    # 访问首页 (对应 visit '/')
    self.driver.get("http://localhost:3000/")
    
    # 检查页面源码是否包含 'Home#top' (对应 expect(page).to have_content('Home#top'))
    page_source = self.driver.page_source
    assert "Home#top" in page_source, "页面应该包含 'Home#top' 文本"
```

## 优势

1. **自动管理浏览器驱动** - 使用webdriver-manager自动下载和管理ChromeDriver/GeckoDriver
2. **多浏览器支持** - 自动尝试Chrome和Firefox
3. **详细日志** - 提供清晰的测试执行过程
4. **错误处理** - 更好的异常处理和调试信息

## 故障排除

### 如果Chrome启动失败
- 确保Chrome浏览器已安装
- 检查网络连接（需要下载ChromeDriver）

### 如果Firefox启动失败
- 确保Firefox浏览器已安装
- 检查网络连接（需要下载GeckoDriver）

### 如果测试失败
- 确保Rails服务器正在运行在 http://localhost:3000
- 检查页面是否包含 "Home#top" 文本
- 查看测试输出的页面源码预览

## 环境要求

- Python 3.7+
- Chrome 或 Firefox 浏览器
- Rails 服务器运行在 localhost:3000 