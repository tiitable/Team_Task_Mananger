# Team Task Manager - Backend Setup Instructions

## Prerequisites
- Ruby 3.0+ installed
- Rails 8.0+ installed
- SQLite3 installed

## Setup Steps

### 1. Install Required Gems
```bash
bundle install
```

### 2. Database Setup
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate
```

### 3. Start the Server
```bash
rails server
```

The API will be available at `http://localhost:3000`

## Key Features Implemented

### ✅ API Authentication
- JWT-based authentication with Devise
- User registration and login
- CORS configuration for Vue.js frontend

### ✅ Workspace Management
- Create and manage workspaces (WorkGroups)  
- Add/remove team members
- Role-based permissions

### ✅ Task Management
- Full CRUD operations for tasks
- Task assignment to multiple users
- Status and priority tracking
- Advanced filtering and search

## Connecting with Vue.js Frontend

Configure your Vue.js API client:

```javascript
import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:3000/api',
  headers: { 'Content-Type': 'application/json' }
})

// Add JWT token to requests
api.interceptors.request.use(config => {
  const token = localStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default api
```

Your backend is now ready for your Vue.js frontend!