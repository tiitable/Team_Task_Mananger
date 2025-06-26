<template>
    <nav class="bg-white shadow-lg border-b border-gray-200">
      <div class="container mx-auto px-4">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center">
            <h1 class="text-xl font-bold text-gray-900">Team Task Manager</h1>
          </div>
          
          <div class="flex items-center space-x-4">
            <button 
              @click="$emit('refresh')"
              class="px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
            >
              Refresh
            </button>
            
            <div v-if="authStore.isAuthenticated" class="flex items-center space-x-2">
              <span class="text-sm text-gray-700">Welcome, {{ authStore.currentUser?.nickname || authStore.currentUser?.email }}</span>
              <button 
                @click="authStore.logout()"
                class="px-3 py-1 text-sm text-red-600 hover:text-red-800 hover:bg-red-50 rounded transition-colors"
              >
                Logout
              </button>
            </div>
            
            <div v-else class="flex items-center space-x-2">
              <a 
                href="/users/sign_in"
                class="px-3 py-1 text-sm text-blue-600 hover:text-blue-800 hover:bg-blue-50 rounded transition-colors"
              >
                Login
              </a>
              <a 
                href="/users/sign_up"
                class="px-3 py-1 text-sm bg-blue-600 text-white hover:bg-blue-700 rounded transition-colors"
              >
                Sign Up
              </a>
            </div>
          </div>
        </div>
      </div>
    </nav>
  </template>
  
  <script setup>
  import { useAuthStore } from '../stores/auth'
  
  const authStore = useAuthStore()
  
  defineEmits(['refresh'])
  </script>