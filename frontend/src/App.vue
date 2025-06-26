<template>
    <div id="app" class="min-h-screen bg-gray-50">
      <Navbar @refresh="fetchPosts" />
      <main class="container mx-auto px-4 py-8">
        <PostsList 
          v-if="currentView === 'list'" 
          @show-post="showPost" 
          @new-post="newPost"
        />
        <PostDetail 
          v-if="currentView === 'detail'" 
          @back="backToList"
          @edit="editPost"
        />
        <PostForm 
          v-if="currentView === 'form'" 
          :post="editingPost"
          @created="onPostCreated" 
          @updated="onPostUpdated"
          @cancel="backToList"
        />
      </main>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import { usePostsStore } from './stores/posts'
  import { useAuthStore } from './stores/auth'
  import Navbar from './components/Navbar.vue'
  import PostsList from './components/PostsList.vue'
  import PostDetail from './components/PostDetail.vue'
  import PostForm from './components/PostForm.vue'
  
  const postsStore = usePostsStore()
  const authStore = useAuthStore()
  
  const currentView = ref('list')
  const editingPost = ref(null)
  
  const fetchPosts = async () => {
    await postsStore.fetchPosts()
    currentView.value = 'list'
  }
  
  const showPost = async (id) => {
    await postsStore.fetchPost(id)
    currentView.value = 'detail'
  }
  
  const newPost = () => {
    editingPost.value = null
    currentView.value = 'form'
  }
  
  const editPost = (post) => {
    editingPost.value = { ...post }
    currentView.value = 'form'
  }
  
  const onPostCreated = () => {
    fetchPosts()
  }
  
  const onPostUpdated = () => {
    fetchPosts()
  }
  
  const backToList = () => {
    currentView.value = 'list'
    editingPost.value = null
  }
  
  onMounted(async () => {
    await authStore.fetchAuthStatus()
    await fetchPosts()
  })
  </script>
  
  <style>
  #app {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }
  
  /* Global styles */
  .container {
    max-width: 1200px;
  }
  
  /* Tailwind-like utilities */
  .min-h-screen { min-height: 100vh; }
  .bg-gray-50 { background-color: #f9fafb; }
  .px-4 { padding-left: 1rem; padding-right: 1rem; }
  .py-8 { padding-top: 2rem; padding-bottom: 2rem; }
  </style>