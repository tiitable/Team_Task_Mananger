<script setup>
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

// 使用用户store
const userStore = useUserStore()
const router = useRouter()

// 初始化用户状态
onMounted(() => {
  userStore.initializeUser()
})

// ログアウト処理
const handleLogout = async () => {
  try {
    // ユーザーストアからログアウト
    userStore.logout()
    
    // ログインページにリダイレクト
    await router.push('/login')
    
    console.log('Logout successful')
  } catch (error) {
    console.error('Logout failed:', error)
  }
}
</script>

<template>
  <VBadge
    dot
    location="bottom right"
    offset-x="3"
    offset-y="3"
    color="success"
    bordered
  >
    <VAvatar
      class="cursor-pointer"
      color="primary"
      variant="tonal"
    >
      <VImg :src="userStore.user.avatar" />

      <!-- SECTION Menu -->
      <VMenu
        activator="parent"
        width="230"
        location="bottom end"
        offset="14px"
      >
        <VList>
          <!-- 👉 User Avatar & Name -->
          <VListItem>
            <template #prepend>
              <VListItemAction start>
                <VBadge
                  dot
                  location="bottom right"
                  offset-x="3"
                  offset-y="3"
                  color="success"
                >
                  <VAvatar
                    color="primary"
                    variant="tonal"
                  >
                    <VImg :src="userStore.user.avatar" />
                  </VAvatar>
                </VBadge>
              </VListItemAction>
            </template>

            <VListItemTitle class="font-weight-semibold">
              {{ userStore.user.username }}
            </VListItemTitle>
            <VListItemSubtitle class="text-caption">
              {{ userStore.user.role }}
            </VListItemSubtitle>
          </VListItem>
          <VDivider class="my-2" />

          <!-- 👉 Profile -->
          <VListItem
            to="/profile"
            link
          >
            <template #prepend>
              <VIcon
                class="me-2"
                icon="ri-user-line"
                size="22"
              />
            </template>

            <VListItemTitle>プロフィール</VListItemTitle>
          </VListItem>


          <!-- work groups -->
          <VListItem 
            to="/work-groups"
            link>
            <template #prepend>
              <VIcon
                class="me-2"
                icon="ri-group-line"
                size="22"
              />
            </template>

            <VListItemTitle>ワークグループ</VListItemTitle>
          </VListItem>

          <!-- Divider -->
          <VDivider class="my-2" />

          <!-- 👉 Logout -->
          <VListItem
            @click="handleLogout"
          >
            <template #prepend>
              <VIcon
                class="me-2"
                icon="ri-logout-box-r-line"
                size="22"
              />
            </template>

            <VListItemTitle>ログアウト</VListItemTitle>
          </VListItem>
        </VList>
      </VMenu>
      <!-- !SECTION -->
    </VAvatar>
  </VBadge>
</template>
