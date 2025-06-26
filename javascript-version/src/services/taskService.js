import api from './api.js'

export const taskService = {
  // Get all tasks for a workspace
  async getTasks(workGroupId) {
    try {
      const response = await api.get(`/work_groups/${workGroupId}/tasks`)
      return response.tasks || []
    } catch (error) {
      console.error('Failed to fetch tasks:', error)
      throw error
    }
  },

  // Get tasks assigned to current user
  async getMyTasks() {
    try {
      const response = await api.get('/my_tasks')
      // Combine assigned and owned tasks into a single array
      const assignedTasks = response.assigned_tasks || []
      const ownedTasks = response.owned_tasks || []
      
      // Use a Set to avoid duplicates (in case user owns and is assigned to same task)
      const allTasks = [...ownedTasks]
      assignedTasks.forEach(task => {
        if (!allTasks.find(t => t.id === task.id)) {
          allTasks.push(task)
        }
      })
      
      return allTasks
    } catch (error) {
      console.error('Failed to fetch my tasks:', error)
      throw error
    }
  },

  // Create a new task
  async createTask(workGroupId, taskData) {
    try {
      const payload = {
        task: {
          title: taskData.title,
          description: taskData.description,
          category: taskData.category || 'feature',
          status: taskData.status || 'open',
          priority: taskData.priority || 'medium',
          due_date: taskData.dueDate || null
        }
      }

      // Add user assignments if provided
      if (taskData.assignedUserIds && taskData.assignedUserIds.length > 0) {
        payload.user_ids = taskData.assignedUserIds
      }

      let response
      if (workGroupId) {
        // Create task within a work group
        response = await api.post(`/work_groups/${workGroupId}/tasks`, payload)
      } else {
        // Create task without work group
        response = await api.post('/tasks', payload)
      }
      
      return response.task
    } catch (error) {
      console.error('Failed to create task:', error)
      throw error
    }
  },

  // Update an existing task
  async updateTask(workGroupId, taskId, taskData) {
    try {
      const payload = {
        task: {
          title: taskData.title,
          description: taskData.description,
          category: taskData.category,
          status: taskData.status,
          priority: taskData.priority,
          due_date: taskData.dueDate
        }
      }

      // Add user assignments if provided
      if (taskData.assignedUserIds) {
        payload.user_ids = taskData.assignedUserIds
      }

      const response = await api.patch(`/work_groups/${workGroupId}/tasks/${taskId}`, payload)
      return response.task
    } catch (error) {
      console.error('Failed to update task:', error)
      throw error
    }
  },

  // Delete a task
  async deleteTask(workGroupId, taskId) {
    try {
      await api.delete(`/work_groups/${workGroupId}/tasks/${taskId}`)
      return true
    } catch (error) {
      console.error('Failed to delete task:', error)
      throw error
    }
  },

  // Get a single task
  async getTask(workGroupId, taskId) {
    try {
      const response = await api.get(`/work_groups/${workGroupId}/tasks/${taskId}`)
      return response.task
    } catch (error) {
      console.error('Failed to fetch task:', error)
      throw error
    }
  },

  // Assign users to a task
  async assignUsers(taskId, userIds) {
    try {
      const response = await api.post(`/tasks/${taskId}/assign_users`, {
        user_ids: userIds
      })
      return response.task
    } catch (error) {
      console.error('Failed to assign users to task:', error)
      throw error
    }
  },

  // Unassign a user from a task
  async unassignUser(taskId, userId) {
    try {
      await api.delete(`/tasks/${taskId}/unassign_user/${userId}`)
      return true
    } catch (error) {
      console.error('Failed to unassign user from task:', error)
      throw error
    }
  }
}

export default taskService