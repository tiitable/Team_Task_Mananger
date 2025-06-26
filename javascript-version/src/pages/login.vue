<script setup>
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

const form = ref({
  email: '',
  password: '',
  remember: false,
})



const isPasswordVisible = ref(false)
const isLoading = ref(false)

// 登录处理
const handleLogin = async () => {
  if (!form.value.email || !form.value.password) {
    alert('メールアドレスとパスワードを入力してください')
    
    return
  }

  isLoading.value = true

  try {
    // Use the store's login method
    const result = await userStore.login(form.value.email, form.value.password)
    
    if (result.success) {
      // Redirect to dashboard using Vue Router
      router.push('/dashboard')
    }
    
  } catch (error) {
    console.error('Login failed:', error)
    alert(error.message || 'ログインに失敗しました。もう一度お試しください。')
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <!-- eslint-disable vue/no-v-html -->

  <div class="auth-wrapper d-flex align-center justify-center pa-4">
    <VCard
      class="auth-card pa-4 pt-7"
      max-width="448"
    >
      <VCardItem class="justify-center">
        <RouterLink
          to="/"
          class="d-flex align-center gap-3"
        >
          <!-- eslint-disable vue/no-v-html -->
          <h2 class="font-weight-medium text-2xl text-center">
            Team Task Manager
          </h2>
        </RouterLink>
      </VCardItem>

      <VCardText class="pt-2">
        <p class="mb-0 text-center">
          ようこそ！登録やログインをしてください
        </p>
      </VCardText>

      <VCardText>
        <VForm @submit.prevent="handleLogin">
          <VRow>
            <!-- email -->
            <VCol cols="12">
              <VTextField
                v-model="form.email"
                label="メールアドレス"
                type="email"
                required
              />
            </VCol>

            <!-- password -->
            <VCol cols="12">
              <VTextField
                v-model="form.password"
                label="パスワード"
                placeholder="············"
                :type="isPasswordVisible ? 'text' : 'password'"
                autocomplete="password"
                :append-inner-icon="isPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                required
                @click:append-inner="isPasswordVisible = !isPasswordVisible"
              />

              <!-- login button -->
              <VBtn 
                class="mt-12"
                block
                type="submit"
                :loading="isLoading"
                :disabled="!form.email || !form.password"
              >
                ログイン
              </VBtn>
            </VCol>

            <!-- create account -->
            <VCol
              cols="12"
              class="text-center text-base"
            >
              <RouterLink
                class="me-2"
                to="/register"
              >
                新規登録はこちら
              </RouterLink>
            </VCol>
          </VRow>
        </VForm>
      </VCardText>
    </VCard>
  </div>
</template>

<style lang="scss">
@use "@core/scss/template/pages/page-auth";
</style>
