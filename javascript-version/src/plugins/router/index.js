import { createRouter, createWebHistory } from 'vue-router'
import { routes } from './routes'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

// Navigation guards for authentication
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // Check if route requires authentication
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  
  // Check if route requires guest (not logged in)
  const requiresGuest = to.matched.some(record => record.meta.requiresGuest)
  
  if (requiresAuth) {
    // Route requires authentication
    if (userStore.isAuthenticated) {
      // User is authenticated, allow access
      next()
    } else {
      // User is not authenticated, redirect to login
      console.log('Access denied: User not authenticated, redirecting to login')
      next('/login')
    }
  } else if (requiresGuest) {
    // Route requires guest (login/register pages)
    if (!userStore.isAuthenticated) {
      // User is not authenticated, allow access to login/register
      next()
    } else {
      // User is already authenticated, redirect to dashboard
      console.log('User already authenticated, redirecting to dashboard')
      next('/dashboard')
    }
  } else {
    // Route has no auth requirements
    next()
  }
})

export default function (app) {
  app.use(router)
}
export { router }
