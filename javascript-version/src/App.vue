<script setup>
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// 应用启动时初始化用户状态
onMounted(() => {
  userStore.initializeUser()
})
</script>

<template>
  <VApp>
    <RouterView />
  </VApp>
</template>
