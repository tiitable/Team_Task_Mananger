<template>
    <div class="flex justify-center">
      <form @submit.prevent="handleSubmit" class="space-y-6 w-3/4 max-w-lg bg-white p-6 shadow rounded">
        <label class="block text-xl font-bold text-gray-700">学習ログ投稿</label>
        <div class="mt-1">
          <label class="text-gray-700 text-lg">タイトル</label>
          <input v-model="form.title" type="text" required placeholder="Railsチュートリアル1章を完了"
            class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm placeholder-gray-400 border border-gray-300 rounded-md" />
        </div>
        <div class="mt-1">
          <label class="text-gray-700 text-lg">本文</label>
          <textarea v-model="form.content" rows="5" required placeholder="環境構築を無事に終えることができた！"
            class="shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm placeholder-gray-400 border border-gray-300 rounded-md"></textarea>
        </div>
        <p class="mt-2 text-sm text-gray-500">
          学習したこと、開発したことを記録しましょう。<br>
          参考にしたサイトがあればURLを書いておくことをオススメします。
        </p>
        <div class="px-4 py-3 text-right sm:px-6">
          <button type="submit"
            class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            ログを記録
          </button>
        </div>
      </form>
    </div>
  </template>
  <script setup>
  import { ref, computed, watch } from 'vue'
  import { usePostsStore } from '../stores/posts'
  const postsStore = usePostsStore()
  const props = defineProps({ post: { type: Object, default: null } })
  const emit = defineEmits(['created', 'updated', 'cancel'])
  const form = ref({ title: '', content: '' })
  const isEditing = computed(() => !!props.post)
  watch(() => props.post, (newPost) => {
    if (newPost) {
      form.value = { title: newPost.title || '', content: newPost.content || '' }
    } else {
      form.value = { title: '', content: '' }
    }
  }, { immediate: true })
  const handleSubmit = async () => {
    if (!form.value.title.trim() || !form.value.content.trim()) return
    try {
      if (isEditing.value) {
        await postsStore.updatePost(props.post.id, form.value)
        emit('updated')
      } else {
        await postsStore.createPost(form.value)
        emit('created')
      }
    } catch (error) {}
  }
  </script>
  