// Base API configuration
const API_BASE_URL = 'http://localhost:3000/api'

// Create API client with common configuration
const createApiClient = () => {
  const makeRequest = async (method, endpoint, data = null) => {
    const token = localStorage.getItem('authToken')
    const config = {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(token && { 'Authorization': `Bearer ${token}` })
      }
    }

    if (data && (method === 'POST' || method === 'PATCH' || method === 'PUT')) {
      config.body = JSON.stringify(data)
    }

    try {
      const response = await fetch(`${API_BASE_URL}${endpoint}`, config)
      const responseData = await response.json()

      if (!response.ok) {
        throw new Error(responseData.message || `HTTP ${response.status}: ${response.statusText}`)
      }

      return responseData
    } catch (error) {
      console.error(`API ${method} ${endpoint} failed:`, error)
      throw error
    }
  }

  return {
    get: (endpoint) => makeRequest('GET', endpoint),
    post: (endpoint, data) => makeRequest('POST', endpoint, data),
    patch: (endpoint, data) => makeRequest('PATCH', endpoint, data),
    put: (endpoint, data) => makeRequest('PUT', endpoint, data),
    delete: (endpoint) => makeRequest('DELETE', endpoint)
  }
}

export default createApiClient()