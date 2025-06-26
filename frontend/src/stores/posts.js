import { defineStore } from 'pinia'
import { postsAPI } from '../api'

export const usePostsStore = defineStore('posts', {
  state: () => ({
    posts: [],
    currentPost: null,
    loading: false,
    error: null
  }),

  getters: {
    sortedPosts: (state) => {
      return [...state.posts].sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    }
  },

  actions: {
    // 获取所有文章
    async fetchPosts() {
      this.loading = true
      this.error = null
      try {
        const response = await postsAPI.getAll()
        this.posts = response.data
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to fetch posts'
        console.error('Error fetching posts:', error)
      } finally {
        this.loading = false
      }
    },

    // 获取单个文章
    async fetchPost(id) {
      this.loading = true
      this.error = null
      try {
        const response = await postsAPI.getById(id)
        this.currentPost = response.data
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to fetch post'
        console.error('Error fetching post:', error)
      } finally {
        this.loading = false
      }
    },

    // 创建文章
    async createPost(postData) {
      this.loading = true
      this.error = null
      try {
        const response = await postsAPI.create(postData)
        this.posts.unshift(response.data)
        return response.data
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to create post'
        console.error('Error creating post:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    // 更新文章
    async updatePost(id, postData) {
      this.loading = true
      this.error = null
      try {
        const response = await postsAPI.update(id, postData)
        const index = this.posts.findIndex(post => post.id === id)
        if (index !== -1) {
          this.posts[index] = response.data
        }
        if (this.currentPost?.id === id) {
          this.currentPost = response.data
        }
        return response.data
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to update post'
        console.error('Error updating post:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    // 删除文章
    async deletePost(id) {
      this.loading = true
      this.error = null
      try {
        await postsAPI.delete(id)
        this.posts = this.posts.filter(post => post.id !== id)
        if (this.currentPost?.id === id) {
          this.currentPost = null
        }
      } catch (error) {
        this.error = error.response?.data?.message || 'Failed to delete post'
        console.error('Error deleting post:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    // 清除错误
    clearError() {
      this.error = null
    }
  }
})