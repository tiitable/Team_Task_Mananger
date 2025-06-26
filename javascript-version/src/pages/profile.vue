<script setup>
import { useUserStore } from '@/stores/user'

// 使用用户store
const userStore = useUserStore()

// 表单数据
const usernameForm = ref({
  newUsername: '',
})

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

// 密码可见性
const isCurrentPasswordVisible = ref(false)
const isNewPasswordVisible = ref(false)
const isConfirmPasswordVisible = ref(false)

// 提交状态
const isUpdatingUsername = ref(false)
const isUpdatingPassword = ref(false)
const isUpdatingAvatar = ref(false)

// 头像上传相关
const fileInput = ref(null)
const selectedFile = ref(null)
const avatarPreview = ref(null)

// 选择文件
const selectFile = () => {
  fileInput.value?.click()
}

// 处理文件选择
const handleFileSelect = event => {
  const file = event.target.files[0]
  if (file) {
    // 获取文件扩展名
    const fileName = file.name.toLowerCase()
    const fileExtension = fileName.split('.').pop()
    
    // 检查文件类型
    if (!file.type.startsWith('image/')) {
      alert('画像ファイルを選択してください')
      
      return
    }
    
    // 检查不支持的文件格式
    const unsupportedFormats = ['heic', 'heif', 'webp']
    if (unsupportedFormats.includes(fileExtension)) {
      alert('HEIC/HEIF/WebP形式は現在サポートされていません。JPEG、PNG、GIF形式の画像を選択してください。')
      
      return
    }
    
    // 验证文件大小 (5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert('ファイルサイズは5MB以下にしてください')
      
      return
    }
    
    selectedFile.value = file
    
    // 创建预览URL
    const reader = new FileReader()

    reader.onload = e => {
      avatarPreview.value = e.target.result
    }
    reader.onerror = () => {
      alert('画像の読み込みに失敗しました。別の画像を選択してください。')
      selectedFile.value = null
    }
    reader.readAsDataURL(file)
  }
}

// 上传头像
const uploadAvatar = async () => {
  if (!selectedFile.value) return
  
  isUpdatingAvatar.value = true
  
  try {
    // 使用store更新头像（现在会调用真实的API）
    await userStore.updateAvatar(selectedFile.value)
    
    // 成功提示
    alert('アバターが正常に更新されました！')
    
    // 清空选择
    selectedFile.value = null
    avatarPreview.value = null
    if (fileInput.value) {
      fileInput.value.value = ''
    }
    
  } catch (error) {
    console.error('Upload failed:', error)
    const errorMessage = error?.message || 'アップロードに失敗しました'
    alert(`アップロードに失敗しました：${errorMessage}`)
  } finally {
    isUpdatingAvatar.value = false
  }
}

// 取消头像选择
const cancelAvatarSelection = () => {
  selectedFile.value = null
  avatarPreview.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// 更新用户名
const updateUsername = async () => {
  if (!usernameForm.value.newUsername.trim()) {
    alert('新しいユーザー名を入力してください')
    return
  }
  
  isUpdatingUsername.value = true
  
  try {
    console.log('Starting username update process')
    // 使用store更新用户名（现在会调用真实的API）
    const result = await userStore.updateUsername(usernameForm.value.newUsername)
    console.log('Received result from updateUsername:', result)
    console.log('Result type:', typeof result)
    console.log('Result success property:', result?.success)
    
    // 成功の場合
    alert('ユーザー名が正常に更新されました！')
    usernameForm.value.newUsername = ''
    
  } catch (error) {
    console.error('Update failed:', error)
    console.error('Error type:', typeof error)
    console.error('Error message:', error.message)
    
    // エラーメッセージを表示
    const errorMessage = error?.message || error?.toString() || 'プロフィールの更新に失敗しました'
    alert(`更新に失敗しました：${errorMessage}`)
  } finally {
    isUpdatingUsername.value = false
  }
}

// 更新密码
const updatePassword = async () => {
  if (!passwordForm.value.currentPassword || 
      !passwordForm.value.newPassword || 
      !passwordForm.value.confirmPassword) {
    return
  }
  
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    return
  }
  
  isUpdatingPassword.value = true
  
  try {
    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // 使用store更新密码
    userStore.updatePassword(passwordForm.value.newPassword)
    
    // 清空表单
    passwordForm.value.currentPassword = ''
    passwordForm.value.newPassword = ''
    passwordForm.value.confirmPassword = ''
    
  } catch (error) {
    console.error('Update failed:', error)
    alert('更新に失敗しました。もう一度お試しください。')
  } finally {
    isUpdatingPassword.value = false
  }
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="d-flex justify-space-between align-center mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          プロフィール設定
        </h1>
        <p class="text-body-1 text-medium-emphasis">
          アカウント情報とプロフィールを管理
        </p>
      </div>
    </div>

    <VCard>
      <VCardText>
        <VRow>
          <!-- 用户头像和基本信息 -->
          <VCol
            cols="12"
            md="4"
          >
            <div class="text-center">
              <!-- 头像上传区域 -->
              <div class="avatar-upload-container mb-4">
                <VAvatar
                  size="120"
                  color="primary"
                  variant="tonal"
                  class="avatar-hover"
                  @click="selectFile"
                >
                  <VImg :src="avatarPreview || userStore.user.avatar" />
                
                  <!-- 悬浮覆盖层 -->
                  <div class="avatar-overlay">
                    <VIcon 
                      icon="ri-camera-line" 
                      size="32"
                      color="white"
                    />
                    <span class="avatar-hint">クリックして変更</span>
                  </div>
                </VAvatar>
              
                <!-- 文件选择输入框 -->
                <input
                  ref="fileInput"
                  type="file"
                  accept="image/jpeg,image/jpg,image/png,image/gif"
                  class="file-input"
                  @change="handleFileSelect"
                >
              
                <!-- 头像操作按钮 -->
                <div
                  v-if="selectedFile"
                  class="avatar-actions mt-3"
                >
                  <VBtn
                    color="primary"
                    size="small"
                    :loading="isUpdatingAvatar"
                    @click="uploadAvatar"
                  >
                    <VIcon
                      icon="ri-upload-line"
                      class="me-1"
                    />
                    アップロード
                  </VBtn>
                
                  <VBtn
                    color="error"
                    size="small"
                    variant="outlined"
                    class="ms-2"
                    @click="cancelAvatarSelection"
                  >
                    <VIcon
                      icon="ri-close-line"
                      class="me-1"
                    />
                    キャンセル
                  </VBtn>
                </div>
              </div>
            
              <h3 class="text-h5 mb-2">
                {{ userStore.user.username }}
              </h3>
            
              <p class="text-body-2 text-medium-emphasis">
                {{ userStore.user.role }}
              </p>
            </div>
          </VCol>

          <!-- 表单区域 -->
          <VCol
            cols="12"
            md="8"
          >
            <VRow>
              <!-- 修改用户名 -->
              <VCol cols="12">
                <VCard variant="outlined">
                  <VCardTitle class="text-h6">
                    <VIcon
                      icon="ri-user-line"
                      class="me-2"
                    />
                    ユーザー名の更新
                  </VCardTitle>
                
                  <VCardText>
                    <VRow>
                      <VCol
                        cols="12"
                        sm="8"
                      >
                        <VTextField
                          v-model="usernameForm.newUsername"
                          label="新しいユーザー名"
                          :placeholder="userStore.user.username"
                          variant="outlined"
                          density="compact"
                        />
                      </VCol>
                    
                      <VCol
                        cols="12"
                        sm="4"
                        class="d-flex align-center"
                      >
                        <VBtn
                          color="primary"
                          :loading="isUpdatingUsername"
                          :disabled="!usernameForm.newUsername.trim()"
                          @click="updateUsername"
                        >
                          ユーザー名を更新
                        </VBtn>
                      </VCol>
                    </VRow>
                  </VCardText>
                </VCard>
              </VCol>

              <!-- 修改密码 -->
              <VCol cols="12">
                <VCard variant="outlined">
                  <VCardTitle class="text-h6">
                    <VIcon
                      icon="ri-lock-line"
                      class="me-2"
                    />
                    パスワードの更新
                  </VCardTitle>
                
                  <VCardText>
                    <VRow>
                      <!-- 当前密码 -->
                      <VCol cols="12">
                        <VTextField
                          v-model="passwordForm.currentPassword"
                          label="現在のパスワード"
                          :type="isCurrentPasswordVisible ? 'text' : 'password'"
                          variant="outlined"
                          density="compact"
                          :append-inner-icon="isCurrentPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                          @click:append-inner="isCurrentPasswordVisible = !isCurrentPasswordVisible"
                        />
                      </VCol>

                      <!-- 新密码 -->
                      <VCol
                        cols="12"
                        sm="6"
                      >
                        <VTextField
                          v-model="passwordForm.newPassword"
                          label="新しいパスワード"
                          :type="isNewPasswordVisible ? 'text' : 'password'"
                          variant="outlined"
                          density="compact"
                          :append-inner-icon="isNewPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                          @click:append-inner="isNewPasswordVisible = !isNewPasswordVisible"
                        />
                      </VCol>

                      <!-- 确认新密码 -->
                      <VCol
                        cols="12"
                        sm="6"
                      >
                        <VTextField
                          v-model="passwordForm.confirmPassword"
                          label="新しいパスワード（確認）"
                          :type="isConfirmPasswordVisible ? 'text' : 'password'"
                          variant="outlined"
                          density="compact"
                          :append-inner-icon="isConfirmPasswordVisible ? 'ri-eye-off-line' : 'ri-eye-line'"
                          :error="passwordForm.newPassword && passwordForm.confirmPassword && passwordForm.newPassword !== passwordForm.confirmPassword"
                          :error-messages="passwordForm.newPassword && passwordForm.confirmPassword && passwordForm.newPassword !== passwordForm.confirmPassword ? 'パスワードが一致しません' : ''"
                          @click:append-inner="isConfirmPasswordVisible = !isConfirmPasswordVisible"
                        />
                      </VCol>

                      <!-- 更新密码按钮 -->
                      <VCol cols="12">
                        <VBtn
                          color="primary"
                          :loading="isUpdatingPassword"
                          :disabled="!passwordForm.currentPassword || !passwordForm.newPassword || !passwordForm.confirmPassword || passwordForm.newPassword !== passwordForm.confirmPassword"
                          @click="updatePassword"
                        >
                          パスワードを更新
                        </VBtn>
                      </VCol>
                    </VRow>
                  </VCardText>
                </VCard>
              </VCol>
            </VRow>
          </VCol>
        </VRow>
      </VCardText>
    </VCard>
  </div>
</template>

<style lang="scss" scoped>
.v-card {
  border-radius: 12px;
}

.avatar-upload-container {
  position: relative;
  display: inline-block;
}

.avatar-hover {
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  
  &:hover {
    transform: scale(1.05);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    
    .avatar-overlay {
      opacity: 1;
    }
  }
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  border-radius: 50%;
}

.avatar-hint {
  color: white;
  font-size: 12px;
  margin-top: 4px;
  text-align: center;
}

.file-input {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.avatar-actions {
  display: flex;
  justify-content: center;
  gap: 8px;
}
</style>
