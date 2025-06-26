import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import avatar1 from '@images/avatars/avatar-1.png'

export const useUserStore = defineStore('user', () => {
  // 状态
  const user = ref({
    id: null,
    username: '',
    email: '',
    avatar: avatar1,
    role: 'チームメンバー',
    isLoggedIn: false,
  })

  const token = ref(null)

  // 计算属性
  const isAuthenticated = computed(() => !!token.value && user.value.isLoggedIn)
  const userInfo = computed(() => user.value)
  const displayName = computed(() => user.value.username)

  // 方法
  const login = async (email, password) => {
    try {
      const response = await fetch('http://localhost:3000/api/auth/sign_in', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          password
        })
      })

      const data = await response.json()

      if (response.ok && data.status === 'success') {
        // 保存用户信息和token
        user.value = {
          id: data.user.id,
          username: data.user.nickname,
          email: data.user.email,
          avatar: data.user.avatar && data.user.avatar.startsWith('data:image') ? data.user.avatar : avatar1,
          role: 'チームメンバー',
          isLoggedIn: true,
        }
        
        token.value = data.token

        // 保存到localStorage
        localStorage.setItem('authToken', data.token)
        localStorage.setItem('user', JSON.stringify(user.value))

        return { success: true, user: data.user }
      } else {
        const errorMessage = data.message || 'ログインに失敗しました'
        throw new Error(errorMessage)
      }
    } catch (error) {
      console.error('Login failed:', error)
      throw error
    }
  }

  // API注册方法
  const register = async (email, password, passwordConfirmation, nickname) => {
    try {
      const response = await fetch('http://localhost:3000/api/auth/sign_up', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user: {
            email,
            password,
            password_confirmation: passwordConfirmation,
            nickname
          }
        })
      })

      const data = await response.json()

      if (response.ok && data.status === 'success') {
        return { success: true, user: data.user }
      } else {
        const errorMessage = data.message || 'アカウント作成に失敗しました'
        throw new Error(errorMessage)
      }
    } catch (error) {
      console.error('Registration failed:', error)
      throw error
    }
  }

  const logout = () => {
    user.value = {
      id: null,
      username: '',
      email: '',
      avatar: avatar1,
      role: '',
      isLoggedIn: false,
    }

    token.value = null

    // 清除localStorage
    localStorage.removeItem('authToken')
    localStorage.removeItem('user')
  }

  const updateUserInfo = updates => {
    user.value = {
      ...user.value,
      ...updates,
    }

    // 更新localStorage
    localStorage.setItem('user', JSON.stringify(user.value))
  }

  const updateUsername = async newUsername => {
    try {
      const authToken = token.value || localStorage.getItem('authToken')
      if (!authToken) {
        throw new Error('認証トークンが見つかりません。再度ログインしてください。')
      }

      console.log('Sending profile update request:', { newUsername })

      const response = await fetch('http://localhost:3000/api/auth/profile', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify({
          user: {
            nickname: newUsername
          }
        })
      })

      console.log('Response status:', response.status)
      console.log('Response headers:', Object.fromEntries(response.headers.entries()))

      const data = await response.json()
      console.log('Response data:', data)

      if (response.ok && data.status === 'success') {
        // Update local state with response data
        user.value.username = data.user.nickname
        user.value.email = data.user.email
        user.value.id = data.user.id
        user.value.avatar = data.user.avatar || user.value.avatar
        localStorage.setItem('user', JSON.stringify(user.value))
        
        console.log('Profile updated successfully')
        return { success: true, user: data.user }
      } else {
        const errorMessage = data.message || data.errors?.join(', ') || 'プロフィールの更新に失敗しました'
        console.log('API returned error:', errorMessage)
        throw new Error(errorMessage)
      }
    } catch (error) {
      console.error('Profile update failed:', error)
      if (error.name === 'TypeError' && error.message.includes('fetch')) {
        throw new Error('サーバーに接続できません。ネットワーク接続を確認してください。')
      }
      throw error
    }
  }

  const updateAvatar = async (avatarFile) => {
    try {
      // Convert file to base64
      const base64Avatar = await fileToBase64(avatarFile)
      console.log('Base64 avatar length:', base64Avatar.length)
      console.log('Base64 avatar starts with:', base64Avatar.substring(0, 50))
      
      const authToken = token.value || localStorage.getItem('authToken')
      if (!authToken) {
        throw new Error('認証トークンが見つかりません。再度ログインしてください。')
      }

      const response = await fetch('http://localhost:3000/api/auth/profile', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: JSON.stringify({
          user: {
            avatar: base64Avatar
          }
        })
      })

      const data = await response.json()
      console.log('Avatar update response:', data)

      if (response.ok && data.status === 'success') {
        // Update local state with response data
        const newAvatar = data.user.avatar || base64Avatar
        console.log('Updating avatar to:', newAvatar ? newAvatar.substring(0, 50) + '...' : 'null')
        
        user.value.avatar = newAvatar
        localStorage.setItem('user', JSON.stringify(user.value))
        
        return { success: true, user: data.user }
      } else {
        const errorMessage = data.message || data.errors?.join(', ') || 'アバターの更新に失敗しました'
        throw new Error(errorMessage)
      }
    } catch (error) {
      console.error('Avatar update failed:', error)
      throw error
    }
  }

  // Helper function to convert file to base64
  const fileToBase64 = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onload = () => resolve(reader.result)
      reader.onerror = error => reject(error)
    })
  }

  const updatePassword = newPassword => {
    // 这里可以调用API更新密码
    // 密码通常不存储在本地状态中
    console.log('Password updated:', newPassword)
  }

  // 初始化时从localStorage恢复用户状态
  const initializeUser = () => {
    const savedToken = localStorage.getItem('authToken')
    const savedUser = localStorage.getItem('user')
    
    if (savedToken && savedUser) {
      try {
        const parsedUser = JSON.parse(savedUser)
        user.value = parsedUser
        token.value = savedToken
        
        console.log('User state restored from localStorage:', parsedUser)
      } catch (error) {
        console.error('Failed to parse saved user data:', error)
        // 清除损坏的数据
        localStorage.removeItem('user')
        localStorage.removeItem('authToken')
      }
    }
  }

  // 检查token是否仍然有效
  const validateToken = async () => {
    const authToken = token.value || localStorage.getItem('authToken')
    if (!authToken) {
      return false
    }

    try {
      const response = await fetch('http://localhost:3000/api/auth/current_user', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${authToken}`
        }
      })

      if (response.ok) {
        return true
      } else {
        // Token无效，清除状态
        logout()
        return false
      }
    } catch (error) {
      console.error('Token validation failed:', error)
      return false
    }
  }

  return {
    // 状态
    user,
    token,
    
    // 计算属性
    isAuthenticated,
    userInfo,
    displayName,
    
    // 方法
    login,
    register,
    logout,
    updateUserInfo,
    updateUsername,
    updateAvatar,
    updatePassword,
    initializeUser,
    validateToken,
  }
})
