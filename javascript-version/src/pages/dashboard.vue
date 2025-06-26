<script setup>
import { ref } from 'vue'

// Current user
const currentUser = ref({
  name: '田中太郎',
  role: 'admin'
})

// Work groups that user is part of
const userWorkGroups = ref([
  {
    id: 1,
    name: 'フロントエンド開発チーム',
    description: 'React、Vue.jsを使用したフロントエンド開発を担当',
    memberCount: 3,
    role: 'admin',
    color: 'primary'
  },
  {
    id: 2,
    name: 'UI/UXデザインチーム',
    description: 'ユーザーインターフェースとユーザーエクスペリエンスの設計',
    memberCount: 3,
    role: 'member',
    color: 'info'
  },
  {
    id: 3,
    name: 'プロジェクト管理チーム',
    description: 'プロジェクトの進行管理と品質保証',
    memberCount: 2,
    role: 'admin',
    color: 'success'
  }
])

// User's assigned tasks
const userTasks = ref([
  {
    id: 1,
    title: 'ダッシュボードUIの改善',
    description: 'ユーザーダッシュボードのレスポンシブデザイン対応',
    dueDate: '2025-01-15',
    status: 'active',
    priority: 'high',
    workGroup: 'フロントエンド開発チーム'
  },
  {
    id: 2,
    title: 'ユーザーフィードバック分析',
    description: 'UI/UXの改善点を特定するためのユーザーフィードバック分析',
    dueDate: '2025-01-20',
    status: 'pending',
    priority: 'medium',
    workGroup: 'UI/UXデザインチーム'
  },
  {
    id: 3,
    title: 'プロジェクト進捗レポート作成',
    description: '月次プロジェクト進捗レポートの作成と配布',
    dueDate: '2025-01-25',
    status: 'active',
    priority: 'high',
    workGroup: 'プロジェクト管理チーム'
  },
  {
    id: 4,
    title: 'コードレビュー',
    description: 'チームメンバーのコードレビューと品質チェック',
    dueDate: '2025-01-18',
    status: 'completed',
    priority: 'medium',
    workGroup: 'フロントエンド開発チーム'
  }
])

// Helper functions
const getStatusText = status => {
  const statusMap = {
    'pending': '待機中',
    'active': '進行中',
    'completed': '完了',
    'cancelled': 'キャンセル'
  }
  return statusMap[status] || status
}

const getStatusColor = status => {
  const colorMap = {
    'pending': 'warning',
    'active': 'success',
    'completed': 'info',
    'cancelled': 'error'
  }
  return colorMap[status] || 'primary'
}

const getPriorityColor = priority => {
  const colorMap = {
    'high': 'error',
    'medium': 'warning',
    'low': 'success'
  }
  return colorMap[priority] || 'primary'
}

const formatDate = dateString => {
  const date = new Date(dateString)
  return date.toLocaleDateString('ja-JP', {
    month: '2-digit',
    day: '2-digit'
  })
}

const getRoleText = role => {
  return role === 'admin' ? '管理者' : 'メンバー'
}

const getRoleColor = role => {
  return role === 'admin' ? 'error' : 'success'
}
</script>

<template>
  <div>
    <!-- Dashboard Header -->
    <div class="d-flex justify-space-between align-center mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-1">
          ダッシュボード
        </h1>
        <p class="text-body-1 text-medium-emphasis mb-0">
          あなたのワークグループとタスクの概要
        </p>
      </div>
    </div>

    <!-- Work Groups and Tasks Row -->
    <VRow class="match-height">
      <!-- Work Groups Section -->
      <VCol
        cols="12"
        md="6"
      >
        <VCard class="h-100">
          <VCardItem>
            <VCardTitle class="d-flex align-center">
              <VIcon
                icon="ri-group-line"
                class="me-2"
              />
              マイワークグループ
            </VCardTitle>
            <template #append>
              <VChip
                size="small"
                color="primary"
              >
                {{ userWorkGroups.length }}グループ
              </VChip>
            </template>
          </VCardItem>

          <VCardText>
            <VList class="card-list">
              <VListItem
                v-for="group in userWorkGroups"
                :key="group.id"
                class="px-0"
              >
                <template #prepend>
                  <VIcon
                    :icon="group.role === 'admin' ? 'ri-shield-star-line' : 'ri-user-line'"
                    :color="group.color"
                    class="me-3"
                  />
                </template>

                <VListItemTitle class="font-weight-medium">
                  {{ group.name }}
                </VListItemTitle>

                <VListItemSubtitle class="text-body-2">
                  {{ group.description }}
                </VListItemSubtitle>

                <template #append>
                  <div class="d-flex flex-column align-end">
                    <VChip
                      size="small"
                      :color="getRoleColor(group.role)"
                      variant="tonal"
                      class="mb-1"
                    >
                      {{ getRoleText(group.role) }}
                    </VChip>
                    <span class="text-caption text-medium-emphasis">
                      {{ group.memberCount }}名
                    </span>
                  </div>
                </template>
              </VListItem>
            </VList>

            <VBtn
              variant="outlined"
              color="primary"
              block
              class="mt-4"
              to="/work-groups"
            >
              <VIcon
                icon="ri-add-line"
                class="me-2"
              />
              ワークグループを管理
            </VBtn>
          </VCardText>
        </VCard>
      </VCol>

      <!-- User Tasks Section -->
      <VCol
        cols="12"
        md="6"
      >
        <VCard class="h-100">
          <VCardItem>
            <VCardTitle class="d-flex align-center">
              <VIcon
                icon="ri-task-line"
                class="me-2"
              />
              マイタスク
            </VCardTitle>
            <template #append>
              <VChip
                size="small"
                color="success"
              >
                {{ userTasks.filter(task => task.status !== 'completed').length }}件進行中
              </VChip>
            </template>
          </VCardItem>

          <VCardText>
            <VList class="card-list">
              <VListItem
                v-for="task in userTasks"
                :key="task.id"
                class="px-0"
              >
                <template #prepend>
                  <VIcon
                    :icon="task.priority === 'high' ? 'ri-alert-line' : task.priority === 'medium' ? 'ri-information-line' : 'ri-checkbox-circle-line'"
                    :color="getPriorityColor(task.priority)"
                    class="me-3"
                  />
                </template>

                <VListItemTitle class="font-weight-medium">
                  {{ task.title }}
                </VListItemTitle>

                <VListItemSubtitle class="text-body-2">
                  {{ task.workGroup }} • {{ formatDate(task.dueDate) }}
                </VListItemSubtitle>

                <template #append>
                  <VChip
                    size="small"
                    :color="getStatusColor(task.status)"
                    variant="tonal"
                  >
                    {{ getStatusText(task.status) }}
                  </VChip>
                </template>
              </VListItem>
            </VList>

            <VBtn
              variant="outlined"
              color="primary"
              block
              class="mt-4"
              to="/tasks"
            >
              <VIcon
                icon="ri-list-check-line"
                class="me-2"
              />
              全タスクを表示
            </VBtn>
          </VCardText>
        </VCard>
      </VCol>
    </VRow>

    <!-- Quick Stats Row -->
    <VRow class="mt-6">
      <VCol
        cols="12"
        sm="6"
        md="3"
      >
        <VCard>
          <VCardText class="text-center">
            <VIcon
              icon="ri-group-line"
              size="48"
              color="primary"
              class="mb-3"
            />
            <h3 class="text-h4 font-weight-bold text-primary">
              {{ userWorkGroups.length }}
            </h3>
            <p class="text-body-2 text-medium-emphasis mb-0">
              参加グループ
            </p>
          </VCardText>
        </VCard>
      </VCol>

      <VCol
        cols="12"
        sm="6"
        md="3"
      >
        <VCard>
          <VCardText class="text-center">
            <VIcon
              icon="ri-task-line"
              size="48"
              color="success"
              class="mb-3"
            />
            <h3 class="text-h4 font-weight-bold text-success">
              {{ userTasks.length }}
            </h3>
            <p class="text-body-2 text-medium-emphasis mb-0">
              総タスク数
            </p>
          </VCardText>
        </VCard>
      </VCol>

      <VCol
        cols="12"
        sm="6"
        md="3"
      >
        <VCard>
          <VCardText class="text-center">
            <VIcon
              icon="ri-time-line"
              size="48"
              color="warning"
              class="mb-3"
            />
            <h3 class="text-h4 font-weight-bold text-warning">
              {{ userTasks.filter(task => task.status !== 'completed').length }}
            </h3>
            <p class="text-body-2 text-medium-emphasis mb-0">
              進行中タスク
            </p>
          </VCardText>
        </VCard>
      </VCol>

      <VCol
        cols="12"
        sm="6"
        md="3"
      >
        <VCard>
          <VCardText class="text-center">
            <VIcon
              icon="ri-shield-star-line"
              size="48"
              color="error"
              class="mb-3"
            />
            <h3 class="text-h4 font-weight-bold text-error">
              {{ userWorkGroups.filter(group => group.role === 'admin').length }}
            </h3>
            <p class="text-body-2 text-medium-emphasis mb-0">
              管理者権限
            </p>
          </VCardText>
        </VCard>
      </VCol>
    </VRow>
  </div>
</template>
