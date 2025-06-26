<template>
    <div class="flex justify-center">
      <div class="space-y-6 w-3/4 max-w-lg">
        <label class="block text-xl font-bold text-gray-700">学習ログ詳細</label>
        <div class="items-center justify-center">
          <div v-if="postsStore.currentPost" tabindex="0" aria-label="card 1" class="focus:outline-none mb-7 bg-white p-6 shadow rounded">
            <div class="flex items-center border-b border-gray-200 pb-6">
              <div class="flex items-start justify-between w-full">
                <div class="pl-3">
                  <p class="focus:outline-none text-lg font-medium leading-5 text-gray-800">{{ postsStore.currentPost.title }}</p>
                  <p class="focus:outline-none text-sm leading-normal pt-2 text-gray-500">by {{ postsStore.currentPost.user?.nickname || postsStore.currentPost.user?.email || 'Unknown' }}</p>
                </div>
                <div v-if="authStore.isAuthenticated && postsStore.currentPost.user_id === authStore.currentUser?.id">
                  <button @click="handleDelete" class="text-sm bg-transparent hover:bg-blue-500 text-blue-700 hover:text-white py-1 px-3 border border-blue-500 hover:border-transparent rounded ml-2">削除</button>
                </div>
              </div>
            </div>
            <div class="px-2">
              <p class="focus:outline-none text-sm leading-5 py-4 text-gray-600">{{ postsStore.currentPost.content }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  <script setup>
  import { usePostsStore } from '../stores/posts'
  import { useAuthStore } from '../stores/auth'
  const postsStore = usePostsStore()
  const authStore = useAuthStore()
  defineEmits(['back', 'edit'])
  const handleDelete = async () => {
    if (!confirm('本当に削除しますか？')) return
    try {
      await postsStore.deletePost(postsStore.currentPost.id)
      emit('back')
    } catch (error) {}
  }
  </script>
  