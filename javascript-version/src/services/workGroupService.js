import api from './api.js'

export const workGroupService = {
  // Get all work groups for current user
  async getWorkGroups() {
    try {
      const response = await api.get('/work_groups')
      return response.work_groups || []
    } catch (error) {
      console.error('Failed to fetch work groups:', error)
      throw error
    }
  },

  // Get user's workspaces
  async getMyWorkspaces() {
    try {
      const response = await api.get('/my_workspaces')
      return response.workspaces || []
    } catch (error) {
      console.error('Failed to fetch my workspaces:', error)
      throw error
    }
  },

  // Create a new work group
  async createWorkGroup(workGroupData) {
    try {
      const payload = {
        work_group: {
          name: workGroupData.name,
          description: workGroupData.description || ''
        }
      }

      const response = await api.post('/work_groups', payload)
      return response.work_group
    } catch (error) {
      console.error('Failed to create work group:', error)
      throw error
    }
  },

  // Update work group
  async updateWorkGroup(workGroupId, workGroupData) {
    try {
      const payload = {
        work_group: {
          name: workGroupData.name,
          description: workGroupData.description
        }
      }

      const response = await api.patch(`/work_groups/${workGroupId}`, payload)
      return response.work_group
    } catch (error) {
      console.error('Failed to update work group:', error)
      throw error
    }
  },

  // Delete work group
  async deleteWorkGroup(workGroupId) {
    try {
      await api.delete(`/work_groups/${workGroupId}`)
      return true
    } catch (error) {
      console.error('Failed to delete work group:', error)
      throw error
    }
  },

  // Add user to work group
  async addUser(workGroupId, userId) {
    try {
      const response = await api.post(`/work_groups/${workGroupId}/add_user`, {
        user_id: userId
      })
      return response.work_group
    } catch (error) {
      console.error('Failed to add user to work group:', error)
      throw error
    }
  },

  // Remove user from work group
  async removeUser(workGroupId, userId) {
    try {
      await api.delete(`/work_groups/${workGroupId}/remove_user`, {
        user_id: userId
      })
      return true
    } catch (error) {
      console.error('Failed to remove user from work group:', error)
      throw error
    }
  }
}

export default workGroupService