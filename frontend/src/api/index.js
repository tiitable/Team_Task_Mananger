import axios from 'axios'

// 配置 axios 默认值
axios.defaults.baseURL = '/api'
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest'
axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

// 请求拦截器
axios.interceptors.request.use(
  config => {
    // 在发送请求之前做些什么
    return config
  },
  error => {
    // 对请求错误做些什么
    return Promise.reject(error)
  }
)

// 响应拦截器
axios.interceptors.response.use(
  response => {
    // 对响应数据做点什么
    return response
  },
  error => {
    // 对响应错误做点什么
    if (error.response?.status === 401) {
      // 未授权，重定向到登录页
      window.location.href = '/users/sign_in'
    }
    return Promise.reject(error)
  }
)

// Posts API
export const postsAPI = {
  // 获取所有文章
  getAll() {
    return axios.get('/posts')
  },

  // 获取单个文章
  getById(id) {
    return axios.get(`/posts/${id}`)
  },

  // 创建文章
  create(data) {
    return axios.post('/posts', data)
  },

  // 更新文章
  update(id, data) {
    return axios.put(`/posts/${id}`, data)
  },

  // 删除文章
  delete(id) {
    return axios.delete(`/posts/${id}`)
  }
}

// Auth API
export const authAPI = {
  // 获取当前用户状态
  getStatus() {
    return axios.get('/auth/status')
  }
}

export default axios