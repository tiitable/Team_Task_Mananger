<script setup>
import { ref } from 'vue'
import avatar1 from '@images/avatars/avatar-1.png'
import avatar2 from '@images/avatars/avatar-2.png'
import avatar3 from '@images/avatars/avatar-3.png'
import avatar4 from '@images/avatars/avatar-4.png'
import avatar5 from '@images/avatars/avatar-5.png'

// Sample user data for the table
const users = ref([
  {
    id: 1,
    name: '田中太郎',
    email: 'tanaka@example.com',
    avatar: avatar1,
    role: 'Admin',
    status: 'Active',
    workGroup: 'フロントエンド開発チーム',
    tasksCompleted: 15,
    lastActive: '2025-01-10',
    joinDate: '2024-01-15'
  },
  {
    id: 2,
    name: '佐藤花子',
    email: 'sato@example.com',
    avatar: avatar2,
    role: 'Member',
    status: 'Active',
    workGroup: 'UI/UXデザインチーム',
    tasksCompleted: 12,
    lastActive: '2025-01-09',
    joinDate: '2024-02-01'
  },
  {
    id: 3,
    name: '高橋美咲',
    email: 'takahashi@example.com',
    avatar: avatar3,
    role: 'Admin',
    status: 'Active',
    workGroup: 'バックエンド開発チーム',
    tasksCompleted: 18,
    lastActive: '2025-01-11',
    joinDate: '2024-01-10'
  },
  {
    id: 4,
    name: '渡辺健太',
    email: 'watanabe@example.com',
    avatar: avatar4,
    role: 'Member',
    status: 'Inactive',
    workGroup: 'フロントエンド開発チーム',
    tasksCompleted: 8,
    lastActive: '2025-01-05',
    joinDate: '2024-03-15'
  },
  {
    id: 5,
    name: '山田美香',
    email: 'yamada@example.com',
    avatar: avatar5,
    role: 'Member',
    status: 'Active',
    workGroup: 'プロジェクト管理チーム',
    tasksCompleted: 20,
    lastActive: '2025-01-11',
    joinDate: '2024-01-20'
  }
])

// Table headers
const headers = [
  { title: 'ユーザー', key: 'user', sortable: false },
  { title: 'ロール', key: 'role', sortable: true },
  { title: 'ワークグループ', key: 'workGroup', sortable: true },
  { title: '完了タスク', key: 'tasksCompleted', sortable: true },
  { title: 'ステータス', key: 'status', sortable: true },
  { title: '最終アクティブ', key: 'lastActive', sortable: true },
  { title: 'アクション', key: 'actions', sortable: false }
]

// Helper functions
const getStatusColor = status => {
  return status === 'Active' ? 'success' : 'error'
}

const getRoleColor = role => {
  return role === 'Admin' ? 'primary' : 'secondary'
}

const formatDate = dateString => {
  const date = new Date(dateString)
  return date.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// Actions
const editUser = user => {
  console.log('Edit user:', user.name)
}

const deleteUser = user => {
  const confirmDelete = confirm(`${user.name}を削除しますか？`)
  if (confirmDelete) {
    const index = users.value.findIndex(u => u.id === user.id)
    if (index > -1) {
      users.value.splice(index, 1)
    }
  }
}

const viewProfile = user => {
  console.log('View profile:', user.name)
}
</script>

<template>
  <VCard>
    <VCardItem>
      <VCardTitle class="d-flex align-center">
        <VIcon
          icon="ri-group-line"
          class="me-2"
        />
        ユーザー管理
      </VCardTitle>
      <template #append>
        <VBtn
          color="primary"
          size="small"
          prepend-icon="ri-add-line"
        >
          新規ユーザー
        </VBtn>
      </template>
    </VCardItem>

    <VCardText>
      <VDataTable
        :headers="headers"
        :items="users"
        :items-per-page="10"
        class="text-no-wrap"
      >
        <!-- User column -->
        <template #item.user="{ item }">
          <div class="d-flex align-center py-2">
            <VAvatar
              :image="item.avatar"
              size="32"
              class="me-3"
            />
            <div>
              <div class="font-weight-medium">
                {{ item.name }}
              </div>
              <div class="text-caption text-medium-emphasis">
                {{ item.email }}
              </div>
            </div>
          </div>
        </template>

        <!-- Role column -->
        <template #item.role="{ item }">
          <VChip
            :color="getRoleColor(item.role)"
            size="small"
            variant="tonal"
          >
            {{ item.role }}
          </VChip>
        </template>

        <!-- Work Group column -->
        <template #item.workGroup="{ item }">
          <span class="text-body-2">
            {{ item.workGroup }}
          </span>
        </template>

        <!-- Tasks Completed column -->
        <template #item.tasksCompleted="{ item }">
          <div class="d-flex align-center">
            <VIcon
              icon="ri-task-line"
              size="16"
              class="me-1"
            />
            <span class="font-weight-medium">{{ item.tasksCompleted }}</span>
          </div>
        </template>

        <!-- Status column -->
        <template #item.status="{ item }">
          <VChip
            :color="getStatusColor(item.status)"
            size="small"
            variant="tonal"
          >
            {{ item.status }}
          </VChip>
        </template>

        <!-- Last Active column -->
        <template #item.lastActive="{ item }">
          <span class="text-body-2">
            {{ formatDate(item.lastActive) }}
          </span>
        </template>

        <!-- Actions column -->
        <template #item.actions="{ item }">
          <div class="d-flex gap-1">
            <VBtn
              icon
              size="small"
              variant="text"
              @click="viewProfile(item)"
            >
              <VIcon
                icon="ri-eye-line"
                size="16"
              />
              <VTooltip activator="parent">
                プロフィール表示
              </VTooltip>
            </VBtn>

            <VBtn
              icon
              size="small"
              variant="text"
              @click="editUser(item)"
            >
              <VIcon
                icon="ri-edit-line"
                size="16"
              />
              <VTooltip activator="parent">
                編集
              </VTooltip>
            </VBtn>

            <VBtn
              icon
              size="small"
              variant="text"
              color="error"
              @click="deleteUser(item)"
            >
              <VIcon
                icon="ri-delete-bin-line"
                size="16"
              />
              <VTooltip activator="parent">
                削除
              </VTooltip>
            </VBtn>
          </div>
        </template>

        <!-- No data -->
        <template #no-data>
          <div class="text-center py-8">
            <VIcon
              icon="ri-user-line"
              size="48"
              class="text-medium-emphasis mb-4"
            />
            <p class="text-body-1 text-medium-emphasis">
              ユーザーが見つかりません
            </p>
          </div>
        </template>
      </VDataTable>
    </VCardText>
  </VCard>
</template>

<style lang="scss" scoped>
:deep(.v-data-table-header th) {
  background-color: rgb(var(--v-theme-surface));
  font-weight: 600;
}

:deep(.v-data-table__tr:hover) {
  background-color: rgba(var(--v-theme-on-surface), 0.04);
}
</style>