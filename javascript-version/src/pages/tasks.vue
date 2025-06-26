<script setup>
import { ref, onMounted, computed } from 'vue'
import { useUserStore } from '@/stores/user'
import AnalyticsUserTable from '@/components/AnalyticsUserTable.vue'
import taskService from '@/services/taskService'
import workGroupService from '@/services/workGroupService'

// Stores
const userStore = useUserStore()

// State
const tasks = ref([])
const isLoading = ref(false)
const error = ref(null)
const successMessage = ref('')

// Dialog states
const showCreateDialog = ref(false)
const showEditDialog = ref(false)
const selectedTask = ref(null)

// Form data
const taskForm = ref({
  title: '',
  description: '',
  category: 'feature',
  status: 'open',
  priority: 'medium',
  dueDate: null
})



// Options for form selects
const categoryOptions = [
  { title: '機能', value: 'feature' },
  { title: 'バグ', value: 'bug' },
  { title: '改善', value: 'enhancement' },
  { title: 'ドキュメント', value: 'documentation' },
  { title: '調査', value: 'research' },
  { title: 'メンテナンス', value: 'maintenance' }
]

const statusOptions = [
  { title: 'オープン', value: 'open' },
  { title: '進行中', value: 'in_progress' },
  { title: 'レビュー', value: 'review' },
  { title: '完了', value: 'completed' },
  { title: 'アーカイブ', value: 'archived' }
]

const priorityOptions = [
  { title: '低', value: 'low' },
  { title: '中', value: 'medium' },
  { title: '高', value: 'high' },
  { title: '緊急', value: 'urgent' }
]

// Computed - removed work group dependencies

// API Functions
const fetchTasks = async () => {
  isLoading.value = true
  try {
    // Use the user's tasks endpoint instead of work group specific tasks
    const data = await taskService.getMyTasks()
    
    // Transform API data to match our display format
    tasks.value = data.map(task => ({
      id: task.id,
      title: task.title,
      description: task.description,
      assignee: task.owner?.nickname || 'Unknown',
      dueDate: task.due_date,
      status: transformStatus(task.status),
      category: task.category,
      priority: task.priority,
      owner: task.owner,
      workgroup: task.workgroup
    }))
  } catch (err) {
    console.error('Failed to fetch tasks:', err)
    // Keep tasks empty on error - show blank table
    tasks.value = []
    error.value = 'タスクの取得に失敗しました。'
  } finally {
    isLoading.value = false
  }
}

const createTask = async () => {
  if (!taskForm.value.title) {
    error.value = 'タイトルは必須です'
    return
  }

  isLoading.value = true
  try {
    const taskData = {
      title: taskForm.value.title,
      description: taskForm.value.description,
      category: taskForm.value.category,
      status: taskForm.value.status,
      priority: taskForm.value.priority,
      dueDate: taskForm.value.dueDate
    }
    
    // Create task without work group (workgroup_id will be null)
    const newTask = await taskService.createTask(null, taskData)
    
    // Add to local tasks list
    const displayTask = {
      id: newTask.id,
      title: newTask.title,
      description: newTask.description,
      assignee: newTask.owner?.nickname || userStore.user?.nickname || 'Unknown',
      dueDate: newTask.due_date,
      status: transformStatus(newTask.status),
      category: newTask.category,
      priority: newTask.priority,
      owner: newTask.owner,
      workgroup: newTask.workgroup
    }
    
    tasks.value.unshift(displayTask)
    closeCreateDialog()
    error.value = null
    successMessage.value = 'タスクが正常に作成されました'
  } catch (err) {
    console.error('Failed to create task:', err)
    error.value = 'タスクの作成に失敗しました: ' + (err.message || 'Unknown error')
  } finally {
    isLoading.value = false
  }
}

// Dialog functions
const openCreateDialog = () => {
  resetForm()
  showCreateDialog.value = true
}

const closeCreateDialog = () => {
  showCreateDialog.value = false
  resetForm()
}

const resetForm = () => {
  taskForm.value = {
    title: '',
    description: '',
    category: 'feature',
    status: 'open',
    priority: 'medium',
    dueDate: null
  }
}

// Lifecycle
onMounted(async () => {
  await fetchTasks()
})

// Helper functions
const getStatusText = status => {
  const statusMap = {
    'pending': '待機中',
    'active': '進行中',
    'completed': '完了',
    'cancelled': 'キャンセル',
    'open': 'オープン',
    'in_progress': '進行中',
    'review': 'レビュー',
    'archived': 'アーカイブ'
  }
  return statusMap[status] || status
}

const getStatusColor = status => {
  const colorMap = {
    'pending': 'warning',
    'active': 'success',
    'completed': 'info',
    'cancelled': 'error',
    'open': 'info',
    'in_progress': 'warning',
    'review': 'secondary',
    'archived': 'grey'
  }
  return colorMap[status] || 'primary'
}

const formatDate = dateString => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

const getCategoryText = category => {
  const categoryMap = {
    'feature': '機能',
    'bug': 'バグ',
    'enhancement': '改善',
    'documentation': 'ドキュメント',
    'research': '調査',
    'maintenance': 'メンテナンス'
  }
  return categoryMap[category] || category
}

const getPriorityText = priority => {
  const priorityMap = {
    'low': '低',
    'medium': '中',
    'high': '高',
    'urgent': '緊急'
  }
  return priorityMap[priority] || priority
}

// Transform status from API to display format
const transformStatus = apiStatus => {
  const statusMap = {
    'open': 'active',
    'in_progress': 'pending',
    'review': 'pending',
    'completed': 'completed',
    'archived': 'cancelled'
  }
  return statusMap[apiStatus] || apiStatus
}

// Table headers
const headers = [
  { title: 'タスク名', key: 'title', align: 'start', width: '40%' }, // 40% of table width
  { title: '担当者', key: 'assignee', align: 'start', width: '150px' }, // Fixed 150px
  { title: '期限', key: 'dueDate', align: 'start', width: '130px' }, // Fixed 130px
  { title: 'ステータス', key: 'status', align: 'start', width: '120px' }, // Fixed 120px
  { title: 'アクション', key: 'actions', align: 'start', width: '120px', sortable: false } // Fixed 120px
]

// Action methods
const editTask = (task) => {
  selectedTask.value = { ...task }
  // Pre-fill form with task data
  taskForm.value = {
    title: task.title,
    description: task.description,
    category: task.category,
    status: task.status,
    priority: task.priority,
    dueDate: task.dueDate,
    workGroupId: task.workgroup?.id || taskForm.value.workGroupId,
    assignedUserIds: task.assigned_users?.map(u => u.id) || []
  }
  showEditDialog.value = true
}

const deleteTask = async (task) => {
  if (!confirm(`タスク「${task.title}」を削除しますか？`)) {
    return
  }

  try {
    await taskService.deleteTask(task.workgroup?.id || taskForm.value.workGroupId, task.id)
    
    // Remove from local tasks list
    const index = tasks.value.findIndex(t => t.id === task.id)
    if (index > -1) {
      tasks.value.splice(index, 1)
    }
    
    successMessage.value = 'タスクが正常に削除されました'
  } catch (err) {
    console.error('Failed to delete task:', err)
    error.value = 'タスクの削除に失敗しました: ' + (err.message || 'Unknown error')
  }
}

const updateTask = async () => {
  if (!taskForm.value.title || !selectedTask.value) {
    error.value = 'タイトルは必須です'
    return
  }

  isLoading.value = true
  try {
    const taskData = {
      title: taskForm.value.title,
      description: taskForm.value.description,
      category: taskForm.value.category,
      status: taskForm.value.status,
      priority: taskForm.value.priority,
      dueDate: taskForm.value.dueDate
    }
    
    const updatedTask = await taskService.updateTask(
      taskForm.value.workGroupId, 
      selectedTask.value.id, 
      taskData
    )
    
    // Update local tasks list
    const index = tasks.value.findIndex(t => t.id === selectedTask.value.id)
    if (index > -1) {
      tasks.value[index] = {
        id: updatedTask.id,
        title: updatedTask.title,
        description: updatedTask.description,
        assignee: updatedTask.owner?.nickname || 'Unknown',
        dueDate: updatedTask.due_date,
        status: transformStatus(updatedTask.status),
        category: updatedTask.category,
        priority: updatedTask.priority,
        owner: updatedTask.owner,
        workgroup: updatedTask.workgroup,
        assigned_users: updatedTask.assigned_users || []
      }
    }
    
    closeEditDialog()
    error.value = null
    successMessage.value = 'タスクが正常に更新されました'
  } catch (err) {
    console.error('Failed to update task:', err)
    error.value = 'タスクの更新に失敗しました: ' + (err.message || 'Unknown error')
  } finally {
    isLoading.value = false
  }
}

const closeEditDialog = () => {
  showEditDialog.value = false
  selectedTask.value = null
  resetForm()
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="d-flex justify-space-between align-center mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold mb-2">
          タスク管理
        </h1>
        <p class="text-body-1 text-medium-emphasis">
          プロジェクトのタスクを効率的に管理
        </p>
      </div>
      <VBtn
        color="primary"
        size="large"
        prepend-icon="ri-add-line"
        @click="openCreateDialog"
      >
        新しいタスクを作成
      </VBtn>
    </div>

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

    <!-- Success Alert -->
    <VAlert
      v-if="successMessage"
      type="success"
      variant="tonal"
      closable
      class="mb-4"
      @click:close="successMessage = ''"
    >
      {{ successMessage }}
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
        タスクを読み込み中...
      </p>
    </div>

    <!-- Tasks Table -->
    <VCard class="mb-6">
      
      <VDataTable
        :headers="headers"
        :items="tasks"
        :items-per-page="10"
        class="elevation-0"
        hover
        hide-default-footer
      >
        <!-- Title Column -->
        <template #item.title="{ item }">
          <div>
            <div class="font-weight-medium text-body-1 mb-1">
              {{ item.title }}
            </div>
            <div class="text-caption text-medium-emphasis">
              {{ item.description }}
            </div>
          </div>
        </template>

        <!-- Assignee Column -->
        <template #item.assignee="{ item }">
          <div class="d-flex align-center">
            <VIcon
              icon="ri-user-line"
              size="16"
              class="me-1"
            />
            {{ item.assignee }}
          </div>
        </template>

        <!-- Due Date Column -->
        <template #item.dueDate="{ item }">
          <div class="d-flex align-center">
            <VIcon
              icon="ri-calendar-line"
              size="16"
              class="me-1"
            />
            {{ formatDate(item.dueDate) }}
          </div>
        </template>

        <!-- Status Column -->
        <template #item.status="{ item }">
          <VChip
            :color="getStatusColor(item.status)"
            size="small"
            variant="tonal"
          >
            {{ getStatusText(item.status) }}
          </VChip>
        </template>

        <!-- Actions Column -->
        <template #item.actions="{ item }">
          <div class="d-flex gap-1">
            <VBtn
              icon="ri-edit-line"
              size="small"
              variant="text"
              color="primary"
              @click="editTask(item)"
            />
            <VBtn
              icon="ri-delete-bin-line"
              size="small"
              variant="text"
              color="error"
              @click="deleteTask(item)"
            />
          </div>
        </template>
      </VDataTable>
    </VCard>

    <!-- Create Task Dialog -->
    <VDialog
      v-model="showCreateDialog"
      max-width="600"
    >
      <VCard>
        <VCardTitle class="text-h6 d-flex align-center">
          <VIcon
            icon="ri-add-line"
            class="me-2"
          />
          新しいタスクを作成
        </VCardTitle>
        
        <VCardText>
          <VForm @submit.prevent="createTask">
            <VRow>
              <VCol cols="12">
                <VTextField
                  v-model="taskForm.title"
                  label="タスク名 *"
                  variant="outlined"
                  density="compact"
                  required
                />
              </VCol>
              
              <VCol cols="12">
                <VTextarea
                  v-model="taskForm.description"
                  label="説明"
                  variant="outlined"
                  density="compact"
                  rows="3"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VSelect
                  v-model="taskForm.category"
                  label="カテゴリー"
                  variant="outlined"
                  density="compact"
                  :items="categoryOptions"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VSelect
                  v-model="taskForm.status"
                  label="ステータス"
                  variant="outlined"
                  density="compact"
                  :items="statusOptions"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VSelect
                  v-model="taskForm.priority"
                  label="優先度"
                  variant="outlined"
                  density="compact"
                  :items="priorityOptions"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VTextField
                  v-model="taskForm.dueDate"
                  label="期限"
                  variant="outlined"
                  density="compact"
                  type="date"
                />
              </VCol>
            </VRow>
          </VForm>
        </VCardText>
        
        <VCardActions>
          <VSpacer />
          <VBtn
            text="キャンセル"
            @click="closeCreateDialog"
          />
          <VBtn
            color="primary"
            text="作成"
            :loading="isLoading"
            @click="createTask"
          />
        </VCardActions>
      </VCard>
    </VDialog>

    <!-- Edit Task Dialog -->
    <VDialog
      v-model="showEditDialog"
      max-width="600"
    >
      <VCard>
        <VCardTitle class="text-h6 d-flex align-center">
          <VIcon
            icon="ri-edit-line"
            class="me-2"
          />
          タスクを編集
        </VCardTitle>
        
        <VCardText>
          <VForm @submit.prevent="updateTask">
            <VRow>
              <VCol cols="12">
                <VTextField
                  v-model="taskForm.title"
                  label="タスク名 *"
                  variant="outlined"
                  density="compact"
                  required
                />
              </VCol>
              
              <VCol cols="12">
                <VTextarea
                  v-model="taskForm.description"
                  label="説明"
                  variant="outlined"
                  density="compact"
                  rows="3"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VSelect
                  v-model="taskForm.category"
                  label="カテゴリー"
                  variant="outlined"
                  density="compact"
                  :items="categoryOptions"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VSelect
                  v-model="taskForm.status"
                  label="ステータス"
                  variant="outlined"
                  density="compact"
                  :items="statusOptions"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VSelect
                  v-model="taskForm.priority"
                  label="優先度"
                  variant="outlined"
                  density="compact"
                  :items="priorityOptions"
                />
              </VCol>
              
              <VCol
                cols="12"
                md="6"
              >
                <VTextField
                  v-model="taskForm.dueDate"
                  label="期限"
                  variant="outlined"
                  density="compact"
                  type="date"
                />
              </VCol>
            </VRow>
          </VForm>
        </VCardText>
        
        <VCardActions>
          <VSpacer />
          <VBtn
            text="キャンセル"
            @click="closeEditDialog"
          />
          <VBtn
            color="primary"
            text="更新"
            :loading="isLoading"
            @click="updateTask"
          />
        </VCardActions>
      </VCard>
    </VDialog>
  </div>
</template>
