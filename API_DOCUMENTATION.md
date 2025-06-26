# Team Task Manager API Documentation

## Overview
This is a comprehensive API for a Notion-like Team Task Manager built with Ruby on Rails and designed to work with a Vue.js frontend. The API provides JWT-based authentication, workspace management, and task management features.

## Base URL
```
http://localhost:3000/api
```

## Authentication
All API endpoints (except authentication endpoints) require a valid JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## API Endpoints

### Authentication Endpoints

#### Sign Up
```http
POST /api/auth/sign_up
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "nickname": "John Doe"
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": "User created successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "John Doe",
    "created_at": "2025-01-15T10:00:00Z"
  }
}
```

#### Sign In
```http
POST /api/auth/sign_in
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Signed in successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "John Doe",
    "created_at": "2025-01-15T10:00:00Z"
  }
}
```
*Note: JWT token is returned in the Authorization header*

## Vue.js Integration Example

```javascript
// API client setup
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Example usage
async function signIn(email, password) {
  const response = await api.post('/auth/sign_in', { email, password });
  const token = response.headers.authorization?.replace('Bearer ', '');
  if (token) {
    localStorage.setItem('authToken', token);
  }
  return response.data;
}
```

For complete API documentation, see the full endpoint list in the project.