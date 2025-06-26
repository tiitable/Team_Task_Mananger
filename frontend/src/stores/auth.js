import { defineStore } from 'pinia'
import { authAPI } from '../api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    authenticated: false,
    loading: false
  }),

  getters: {
    isAuthenticated: (state) => state.authenticated,
    currentUser: (state) => state.user
  },

  actions: {
    // 获取认证状态
    async fetchAuthStatus() {
      this.loading = true
      try {
        const response = await authAPI.getStatus()
        this.user = response.data.user
        this.authenticated = response.data.authenticated
      } catch (error) {
        this.user = null
        this.authenticated = false
        console.error('Error fetching auth status:', error)
      } finally {
        this.loading = false
      }
    },

    // 登出
    logout() {
      this.user = null
      this.authenticated = false
      window.location.href = '/users/sign_out'
    }
  }
})