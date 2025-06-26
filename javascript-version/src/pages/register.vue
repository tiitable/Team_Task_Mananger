<script setup>
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

const form = ref({
  username: '',
  email: '',
  password: '',
  confirmPassword: '',
  privacyPolicies: false,
})

const passwordError = computed(() => {
  return form.value.confirmPassword && form.value.password !== form.value.confirmPassword
    ? 'パスワードが一致しません'
    : ''
})



const isPasswordVisible = ref(false)
const isLoading = ref(false)

// 新規登録処理
const handleRegister = async () => {
  if (!form.value.username || !form.value.email || !form.value.password) {
    alert('すべての項目を入力してください')
    return
  }

  if (form.value.password !== form.value.confirmPassword) {
    alert('パスワードが一致しません')
    return
  }

  isLoading.value = true

  try {
    // Use the store's register method
    const result = await userStore.register(
      form.value.email,
      form.value.password,
      form.value.confirmPassword,
      form.value.username
    )

    if (result.success) {
      alert('登録が完了しました！ログインしてください。')
      router.push('/login')
    }
    
  } catch (error) {
    console.error('Registration failed:', error)
    alert(error.message || 'ネットワークエラーです。バックエンドサーバーが動作していることを確認してください。')
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
          <h2 class="font-weight-medium text-2xl text-center">
            Team Task Manager
          </h2>
        </RouterLink>
      </VCardItem>

      <VCardText class="pt-2">
        <h4 class="text-h5 mb-1">
          新規登録
        </h4>
      </VCardText>

      <VCardText>
        <VForm @submit.prevent="handleRegister">
          <VRow>
            <!-- Username -->
            <VCol cols="12">
              <VTextField
                v-model="form.username"
                label="ユーザー名"
                required
              />
            </VCol>
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
                :type="isPasswordVisible ? 'text' : 'password'"
                autocomplete="password"
                :append-inner-icon="isPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                required
                @click:append-inner="isPasswordVisible = !isPasswordVisible"
              />
            </VCol>

            <!-- confirm password -->
            <VCol cols="12">
              <VTextField 
                v-model="form.confirmPassword"
                label="パスワード（確認）"
                :type="isPasswordVisible ? 'text' : 'password'"
                :error="!!passwordError"
                :error-messages="passwordError"
                required
              />
            </VCol>

            <VCol cols="12">
              <VBtn
                class="mt-12"
                block
                type="submit"
                :loading="isLoading"
                :disabled="!form.username || !form.email || !form.password || !form.confirmPassword || !!passwordError"
              >
                新規登録
              </VBtn>
            </VCol>
            
            <!-- login link -->
            <VCol
              cols="12"
              class="text-center text-base"
            >
              <span>すでにアカウントをお持ちですか？ </span>
              <RouterLink
                class="me-2"
                to="/login"
              >
                ログインはこちら
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
