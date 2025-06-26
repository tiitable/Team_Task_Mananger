<script setup>
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'
import VerticalNavSectionTitle from '@/@layouts/components/VerticalNavSectionTitle.vue'
import VerticalNavGroup from '@layouts/components/VerticalNavGroup.vue'
import VerticalNavLink from '@layouts/components/VerticalNavLink.vue'

const userStore = useUserStore()
const router = useRouter()

// ログアウト処理
const handleLogout = async () => {
  try {
    // ユーザーストアからログアウト
    userStore.logout()
    
    // ログインページにリダイレクト
    await router.push('/login')
    
    console.log('Logout successful from sidebar')
  } catch (error) {
    console.error('Logout failed:', error)
  }
}
</script>

<template>
  <div class="nav-items-container">
    <div class="main-nav-items">
      <VerticalNavLink
        :item="{
          title: 'ダッシュボード',
          icon: 'ri-home-smile-line',
          to: '/dashboard',
        }"
      />
      <VerticalNavLink
        :item="{
          title: 'タスク',
          icon: 'ri-task-line',
          to: '/tasks',
        }"
      />
      <VerticalNavLink
        :item="{
          title: 'ワークグループ',
          icon: 'ri-group-line',
          to: '/work-groups',
        }"
      />

      <!--
        <VerticalNavLink
        :item="{
        title: 'ノート',
        icon: 'ri-pencil-line',
        to: '/notes',
        }"
        /> 
      -->
      <VerticalNavLink
        :item="{
          title: 'プロフィール',
          icon: 'ri-user-line',
          to: '/Profile',
        }"
      />
    </div>

    <!-- 固定在底部的logout按钮 -->
    <div class="bottom-nav-items">
      <li
        class="nav-link logout-button"
        @click="handleLogout"
      >
        <a class="logout-link">
          <VIcon
            icon="ri-logout-box-line"
            class="nav-item-icon"
          />
          <span class="nav-item-title">ログアウト</span>
        </a>
      </li>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.nav-items-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.main-nav-items {
  flex: 1;
}

.bottom-nav-items {
  margin-top: auto;
  padding-top: 1rem;
  border-top: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));
}

.logout-button {
  cursor: pointer;
  transition: background-color 0.2s ease;
  
  &:hover {
    background-color: rgba(var(--v-theme-primary), 0.08);
  }
  
  .logout-link {
    display: flex;
    align-items: center;
    text-decoration: none;
    color: inherit;
    padding: 0.75rem 1rem;
    width: 100%;
  }
  
  .nav-item-icon {
    margin-right: 0.75rem;
    font-size: 1.25rem;
  }
  
  .nav-item-title {
    font-size: 0.875rem;
    font-weight: 400;
  }
}
</style>
