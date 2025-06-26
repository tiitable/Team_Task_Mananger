<script setup>
import { ref, onMounted } from 'vue'
import avatar1 from '@images/avatars/avatar-1.png'
import avatar2 from '@images/avatars/avatar-2.png'
import avatar3 from '@images/avatars/avatar-3.png'
import avatar4 from '@images/avatars/avatar-4.png'
import avatar5 from '@images/avatars/avatar-5.png'

// API state
const isLoading = ref(false)
const error = ref(null)

// Sample work groups data (fallback for demo)
const workGroups = ref([
  {
    id: 1,
    name: 'フロントエンド開発チーム',
    description: 'React、Vue.jsを使用したフロントエンド開発を担当',
    members: [
      { name: '田中太郎', avatar: avatar1, memberRole: 'admin' },
      { name: '佐藤花子', avatar: avatar2, memberRole: 'member' },
    ],
    projects: 3,
    role: 'admin',
    createdDate: '2024-01-15',
    color: 'primary',
  },
  {
    id: 2,
    name: 'バックエンド開発チーム',
    description: 'Node.js、Python、Go言語でのサーバーサイド開発',
    members: [
      { name: '高橋美咲', avatar: avatar4, memberRole: 'admin' },
      { name: '渡辺健太', avatar: avatar5, memberRole: 'member' },
    ],
    projects: 5,
    role: 'member',
    createdDate: '2024-01-10',
    color: 'success',
  },
])

// API functions (simplified for now)
const fetchWorkGroups = async () => {
  isLoading.value = true
  error.value = null
  
  try {
    // Try to fetch from Rails API
    const token = localStorage.getItem('authToken')
    const response = await fetch('http://localhost:3000/api/work_groups', {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : ''
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.work_groups && data.work_groups.length > 0) {
        // Transform API data to match our format
        workGroups.value = data.work_groups.map(wg => ({
          id: wg.id,
          name: wg.name,
          description: wg.description,
          members: wg.users || [],
          projects: 0, // This would come from tasks count
          role: 'member', // This would come from user's role in the group
          createdDate: wg.created_at,
          color: 'primary'
        }))
      }
    } else {
      console.log('API not available, using sample data')
    }
  } catch (err) {
    console.log('Using sample data as API is not available:', err.message)
    error.value = null // Don't show error for API unavailability
  } finally {
    isLoading.value = false
  }
}

// Load work groups on component mount
onMounted(() => {
  fetchWorkGroups()
})

// Create new work group dialog
const showCreateDialog = ref(false)

const newGroupForm = ref({
  name: '',
  description: '',
  members: [],
  role: 'member',
  color: 'primary',
})

// Detail dialog
const showDetailDialog = ref(false)
const selectedGroupForDetail = ref(null)

// Current user (for admin permissions)
const currentUser = ref({
  name: '田中太郎', // This would come from user store in real app
  role: 'admin', // This determines if user can delete members
})

const availableUsers = [
  { name: '田中太郎', avatar: avatar1 },
  { name: '佐藤花子', avatar: avatar2 },
  { name: '高橋美咲', avatar: avatar4 },
  { name: '渡辺健太', avatar: avatar5 },
]

const colorOptions = [
  { title: 'プライマリー', value: 'primary' },
  { title: 'サクセス', value: 'success' },
  { title: 'インフォ', value: 'info' },
  { title: 'ワーニング', value: 'warning' },
]

const openCreateDialog = () => {
  showCreateDialog.value = true
}

const closeCreateDialog = () => {
  showCreateDialog.value = false
  resetForm()
}

const resetForm = () => {
  newGroupForm.value = {
    name: '',
    description: '',
    members: [],
    role: 'member',
    color: 'primary',
  }
}

const createWorkGroup = async () => {
  if (!newGroupForm.value.name || !newGroupForm.value.description) {
    alert('必須項目を入力してください')
    return
  }

  isLoading.value = true

  try {
    const newGroupData = {
      name: newGroupForm.value.name,
      description: newGroupForm.value.description,
      members: newGroupForm.value.members.map(memberName => {
        const user = availableUsers.find(u => u.name === memberName)
        return { 
          name: memberName, 
          avatar: user?.avatar || avatar1,
          memberRole: 'member',
        }
      }),
      projects: 0,
      role: newGroupForm.value.role,
      color: newGroupForm.value.color,
    }

    // Try to create via API
    try {
      const token = localStorage.getItem('authToken')
      const response = await fetch('http://localhost:3000/api/work_groups', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : ''
        },
        body: JSON.stringify({
          work_group: {
            name: newGroupData.name,
            description: newGroupData.description
          }
        })
      })

      if (response.ok) {
        const data = await response.json()
        const createdGroup = {
          id: data.work_group.id,
          name: data.work_group.name,
          description: data.work_group.description,
          members: [],
          projects: 0,
          role: 'admin', // Creator is admin
          createdDate: data.work_group.created_at,
          color: newGroupData.color
        }
        workGroups.value.push(createdGroup)
        alert('ワークグループが作成されました！')
      } else {
        throw new Error('API creation failed')
      }
    } catch (apiError) {
      console.log('API not available, creating locally:', apiError.message)
      
      // Fallback to local creation
      const newGroup = {
        id: workGroups.value.length + 1,
        ...newGroupData,
        createdDate: new Date().toISOString().split('T')[0],
      }
      workGroups.value.push(newGroup)
      alert('ワークグループが作成されました！（ローカルのみ）')
    }

    closeCreateDialog()
  } catch (error) {
    console.error('Error creating work group:', error)
    alert('ワークグループの作成に失敗しました')
  } finally {
    isLoading.value = false
  }
}

const formatDate = dateString => {
  const date = new Date(dateString)
  
  return date.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  })
}

const getRoleText = role => {
  const roleMap = {
    'admin': '管理者',
    'member': 'メンバー',
  }
  
  return roleMap[role] || role
}

const getRoleColor = role => {
  const colorMap = {
    'admin': 'error',
    'member': 'success',
  }
  
  return colorMap[role] || 'primary'
}

// Detail dialog functions
const openDetailDialog = group => {
  selectedGroupForDetail.value = group
  showDetailDialog.value = true
}

const closeDetailDialog = () => {
  showDetailDialog.value = false
  selectedGroupForDetail.value = null
}

// Check if current user can delete members (must be admin in the group)
const canDeleteMembers = () => {
  if (!selectedGroupForDetail.value) return false
  
  return currentUser.value.role === 'admin' || selectedGroupForDetail.value.role === 'admin'
}

// Delete member from group
const deleteMember = async memberName => {
  if (!selectedGroupForDetail.value || !canDeleteMembers()) return
  
  const confirmDelete = confirm(`${memberName}をグループから削除しますか？`)
  if (!confirmDelete) return

  try {
    const groupId = selectedGroupForDetail.value.id
    const member = selectedGroupForDetail.value.members.find(m => m.name === memberName)
    
    // Try to remove via API
    try {
      const token = localStorage.getItem('authToken')
      const response = await fetch(`http://localhost:3000/api/work_groups/${groupId}/remove_user`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : ''
        },
        body: JSON.stringify({
          user_id: member.id || memberName
        })
      })

      if (!response.ok) {
        throw new Error('API removal failed')
      }
    } catch (apiError) {
      console.log('API not available, removing locally:', apiError.message)
    }

    // Update local state regardless of API success
    const group = workGroups.value.find(g => g.id === groupId)
    if (group) {
      group.members = group.members.filter(member => member.name !== memberName)
      // Update the selected group for detail as well
      selectedGroupForDetail.value.members = group.members
    }
    
    alert('メンバーが削除されました')
  } catch (error) {
    console.error('Error removing member:', error)
    alert('メンバーの削除に失敗しました')
  }
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="d-flex justify-space-between align-center mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          ワークグループ
        </h1>
        <p class="text-body-1 text-medium-emphasis">
          プロジェクトチームとワークグループを管理
        </p>
      </div>
      <VBtn
        color="primary"
        size="large"
        prepend-icon="ri-add-line"
        @click="openCreateDialog"
      >
        新しいグループを作成
      </VBtn>
    </div>

    <!-- Stats Cards -->
    <VRow class="mb-6">
      <VCol
        cols="12"
        sm="6"
        md="3"
      >
        <VCard>
          <VCardText class="text-center">
            <VIcon
              icon="ri-group-line"
              size="40"
              color="primary"
              class="mb-2"
            />
            <h3 class="text-h4 font-weight-bold">
              {{ workGroups.length }}
            </h3>
            <p class="text-body-2 text-medium-emphasis mb-0">
              総グループ数
            </p>
          </VCardText>
        </VCard>
      </VCol>
    </VRow>

    <!-- Error Alert -->
    <VAlert
      v-if="error"
      type="error"
      variant="tonal"
      closable
      class="mb-4"
      @click:close="error = null"
    >
      {{ error }}
    </VAlert>

    <!-- Loading State -->
    <div
      v-if="isLoading"
      class="text-center py-8"
    >
      <VProgressCircular
        indeterminate
        color="primary"
        size="64"
      />
      <p class="text-body-1 mt-4">
        ワークグループを読み込み中...
      </p>
    </div>

    <!-- Work Groups Grid -->
    <VRow v-else>
      <VCol
        v-for="group in workGroups"
        :key="group.id"
        cols="12"
        md="6"
        lg="4"
      >
        <VCard class="work-group-card h-100">
          <VCardText>
            <div class="d-flex justify-space-between align-start mb-4">
              <div class="flex-grow-1">
                <h3 class="text-h6 font-weight-medium mb-1">
                  {{ group.name }}
                </h3>
                <p class="text-body-2 text-medium-emphasis mb-0">
                  {{ group.description }}
                </p>
              </div>
              <VChip
                :color="getRoleColor(group.role)"
                size="small"
                class="text-capitalize"
              >
                {{ getRoleText(group.role) }}
              </VChip>
            </div>

            <div class="mb-4">
              <div class="d-flex align-center justify-space-between mb-2">
                <span class="text-body-2 font-weight-medium">メンバー</span>
                <span class="text-caption text-medium-emphasis">{{ group.members.length }}人</span>
              </div>
              <div class="d-flex align-center gap-x-2">
                <VAvatar
                  v-for="member in group.members.slice(0, 4)"
                  :key="member.name"
                  size="32"
                  :src="member.avatar"
                  :title="member.name + ' (' + (member.memberRole === 'admin' ? '管理者' : 'メンバー') + ')'"
                />
              </div>
            </div>

            <div class="d-flex justify-space-between align-center mb-4">
              <div class="text-center">
                <h4
                  class="text-h6 font-weight-bold"
                  :class="`text-${group.color}`"
                >
                  {{ group.projects }}
                </h4>
                <p class="text-caption text-medium-emphasis mb-0">
                  プロジェクト
                </p>
              </div>
              <div class="text-center">
                <h4 class="text-h6 font-weight-bold">
                  {{ formatDate(group.createdDate) }}
                </h4>
                <p class="text-caption text-medium-emphasis mb-0">
                  作成日
                </p>
              </div>
            </div>

            <div class="d-flex gap-2">
              <VBtn
                variant="outlined"
                size="small"
                prepend-icon="ri-eye-line"
                class="flex-grow-1"
                @click="openDetailDialog(group)"
              >
                詳細
              </VBtn>
              <VBtn
                variant="outlined"
                size="small"
                prepend-icon="ri-edit-line"
                class="flex-grow-1"
              >
                編集
              </VBtn>
            </div>
          </VCardText>
        </VCard>
      </VCol>
    </VRow>

    <!-- Create Work Group Dialog -->
    <VDialog
      v-model="showCreateDialog"
      max-width="600"
      persistent
    >
      <VCard>
        <VCardTitle class="text-h6 d-flex align-center">
          <VIcon
            icon="ri-group-line"
            class="me-2"
          />
          新しいワークグループを作成
        </VCardTitle>
        
        <VCardText>
          <VForm @submit.prevent="createWorkGroup">
            <VRow>
              <VCol cols="12">
                <VTextField
                  v-model="newGroupForm.name"
                  label="グループ名 *"
                  variant="outlined"
                  density="compact"
                  required
                />
              </VCol>
              
              <VCol cols="12">
                <VTextarea
                  v-model="newGroupForm.description"
                  label="説明 *"
                  variant="outlined"
                  density="compact"
                  rows="3"
                  required
                />
              </VCol>
              
              <VCol cols="12">
                <VSelect
                  v-model="newGroupForm.members"
                  label="メンバーを選択"
                  variant="outlined"
                  density="compact"
                  :items="availableUsers.map(user => user.name)"
                  multiple
                  chips
                  closable-chips
                />
              </VCol>
              
              <VCol cols="12">
                <VSelect
                  v-model="newGroupForm.role"
                  label="あなたの役割"
                  variant="outlined"
                  density="compact"
                  :items="[
                    { title: '管理者', value: 'admin' },
                    { title: 'メンバー', value: 'member' }
                  ]"
                />
              </VCol>
              
              <VCol cols="12">
                <p class="text-body-2 font-weight-medium mb-2">
                  グループカラー
                </p>
                <div class="d-flex flex-wrap gap-2">
                  <VChip
                    v-for="colorOption in colorOptions"
                    :key="colorOption.value"
                    :color="colorOption.value"
                    :variant="newGroupForm.color === colorOption.value ? 'flat' : 'outlined'"
                    class="cursor-pointer"
                    @click="newGroupForm.color = colorOption.value"
                  >
                    {{ colorOption.title }}
                  </VChip>
                </div>
              </VCol>
            </VRow>
          </VForm>
        </VCardText>
        
        <VCardActions>
          <VSpacer />
          <VBtn
            color="secondary"
            variant="outlined"
            @click="closeCreateDialog"
          >
            キャンセル
          </VBtn>
          <VBtn
            color="primary"
            @click="createWorkGroup"
          >
            作成
          </VBtn>
        </VCardActions>
      </VCard>
    </VDialog>

    <!-- Group Detail Dialog -->
    <VDialog
      v-model="showDetailDialog"
      max-width="700"
      persistent
    >
      <VCard v-if="selectedGroupForDetail">
        <VCardTitle class="text-h6 d-flex align-center">
          <VIcon
            icon="ri-group-line"
            class="me-2"
          />
          {{ selectedGroupForDetail.name }} - メンバー詳細
        </VCardTitle>
        
        <VCardText>
          <!-- Group Info -->
          <div class="mb-6">
            <div class="d-flex justify-space-between align-center mb-4">
              <div>
                <h3 class="text-h6 font-weight-medium mb-1">
                  {{ selectedGroupForDetail.name }}
                </h3>
                <p class="text-body-2 text-medium-emphasis">
                  {{ selectedGroupForDetail.description }}
                </p>
              </div>
              <VChip
                :color="getRoleColor(selectedGroupForDetail.role)"
                size="small"
              >
                {{ getRoleText(selectedGroupForDetail.role) }}
              </VChip>
            </div>
            
            <div class="d-flex gap-4 text-center">
              <div>
                <h4
                  class="text-h6 font-weight-bold"
                  :class="`text-${selectedGroupForDetail.color}`"
                >
                  {{ selectedGroupForDetail.projects }}
                </h4>
                <p class="text-caption text-medium-emphasis mb-0">
                  プロジェクト
                </p>
              </div>
              <div>
                <h4 class="text-h6 font-weight-bold">
                  {{ formatDate(selectedGroupForDetail.createdDate) }}
                </h4>
                <p class="text-caption text-medium-emphasis mb-0">
                  作成日
                </p>
              </div>
              <div>
                <h4 class="text-h6 font-weight-bold">
                  {{ selectedGroupForDetail.members.length }}
                </h4>
                <p class="text-caption text-medium-emphasis mb-0">
                  メンバー数
                </p>
              </div>
            </div>
          </div>

          <!-- Members List -->
          <div>
            <div class="d-flex justify-space-between align-center mb-4">
              <h4 class="text-h6 font-weight-medium">
                メンバー一覧
              </h4>
              <VChip
                v-if="canDeleteMembers()"
                color="info"
                size="small"
                prepend-icon="ri-shield-user-line"
              >
                管理者権限
              </VChip>
            </div>
            
            <VList class="pa-0">
              <VListItem
                v-for="(member, index) in selectedGroupForDetail.members"
                :key="member.name"
                class="member-item"
                :class="{ 'border-bottom': index < selectedGroupForDetail.members.length - 1 }"
              >
                <template #prepend>
                  <VAvatar
                    size="40"
                    :src="member.avatar"
                    class="me-3"
                  />
                </template>
                
                <VListItemTitle class="font-weight-medium">
                  {{ member.name }}
                </VListItemTitle>
                
                <VListItemSubtitle>
                  <VChip
                    :color="member.memberRole === 'admin' ? 'error' : 'success'"
                    size="small"
                    variant="tonal"
                  >
                    {{ member.memberRole === 'admin' ? '管理者' : 'メンバー' }}
                  </VChip>
                </VListItemSubtitle>

                <template #append>
                  <VBtn
                    v-if="canDeleteMembers() && member.name !== currentUser.name"
                    icon
                    variant="text"
                    color="error"
                    size="small"
                    @click="deleteMember(member.name)"
                  >
                    <VIcon icon="ri-delete-bin-line" />
                  </VBtn>
                  <VTooltip
                    v-else-if="member.name === currentUser.name"
                    activator="parent"
                    location="top"
                  >
                    自分は削除できません
                  </VTooltip>
                </template>
              </VListItem>
            </VList>
            
            <VAlert
              v-if="selectedGroupForDetail.members.length === 0"
              type="info"
              variant="tonal"
              class="mt-4"
            >
              このグループにはメンバーがいません
            </VAlert>
          </div>
        </VCardText>
        
        <VCardActions>
          <VSpacer />
          <VBtn
            color="secondary"
            variant="outlined"
            @click="closeDetailDialog"
          >
            閉じる
          </VBtn>
        </VCardActions>
      </VCard>
    </VDialog>
  </div>
</template>

<style lang="scss" scoped>
.work-group-card {
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }
}

.cursor-pointer {
  cursor: pointer;
}

.gap-x-2 {
  gap: 8px;
}

.gap-2 {
  gap: 8px;
}

.h-100 {
  height: 100%;
}

.member-item {
  padding: 12px 16px;
  transition: background-color 0.2s ease;
  
  &:hover {
    background-color: rgba(var(--v-theme-primary), 0.04);
  }
  
  &.border-bottom {
    border-bottom: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));
  }
}
</style>
