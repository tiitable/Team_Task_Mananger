<template>
    <div class="flex justify-center">
      <div class="space-y-6 w-3/4 max-w-lg">
        <label class="block text-xl font-bold text-gray-700">学習ログ一覧</label>
        <div class="items-center justify-center">
          <div v-for="post in postsStore.sortedPosts" :key="post.id" tabindex="0" aria-label="card 1" class="focus:outline-none mb-7 bg-white p-6 shadow rounded">
            <div class="flex items-center border-b border-gray-200 pb-6">
              <div class="flex items-start justify-between w-full">
                <div class="pl-3">
                  <p class="focus:outline-none text-lg font-medium leading-5 text-gray-800">
                    <a @click.prevent="$emit('show-post', post.id)" href="#" class="hover:text-blue-600 transition-colors cursor-pointer">{{ post.title }}</a>
                  </p>
                  <p class="focus:outline-none text-sm leading-normal pt-2 text-gray-500">by {{ post.user?.nickname || post.user?.email || 'Unknown' }}</p>
                </div>
              </div>
            </div>
            <div class="px-2">
              <p class="focus:outline-none text-sm leading-5 py-4 text-gray-600">{{ post.content }}</p>
            </div>
          </div>
        </div>
        <div v-if="postsStore.error" class="mt-4 p-4 bg-red-50 border border-red-200 rounded-md">
          <p class="text-red-600">{{ postsStore.error }}</p>
          <button @click="postsStore.clearError()" class="mt-2 text-sm text-red-500 hover:text-red-700">Dismiss</button>
        </div>
      </div>
    </div>
  </template>
  <script setup>
  import { usePostsStore } from '../stores/posts'
  const postsStore = usePostsStore()
  defineEmits(['show-post'])
  </script>
  