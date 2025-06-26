export const routes = [
  { path: '/', redirect: '/dashboard' }, // Redirect to dashboard by default
  {
    path: '/',
    component: () => import('@/layouts/default.vue'),
    meta: { requiresAuth: true }, // All routes under this layout require authentication
    children: [
      {
        path: 'dashboard',
        component: () => import('@/pages/dashboard.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'profile',
        component: () => import('@/pages/profile.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'tasks',
        component: () => import('@/pages/tasks.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'work-groups',
        component: () => import('@/pages/work-groups.vue'),
        meta: { requiresAuth: true },
      },
    ],
  },
  {
    path: '/',
    component: () => import('@/layouts/blank.vue'),
    children: [
      {
        path: 'login',
        component: () => import('@/pages/login.vue'),
        meta: { requiresGuest: true }, // Only accessible when not logged in
      },
      {
        path: 'register',
        component: () => import('@/pages/register.vue'),
        meta: { requiresGuest: true }, // Only accessible when not logged in
      },
      {
        path: '/:pathMatch(.*)*',
        component: () => import('@/pages/[...error].vue'),
      },
    ],
  },
]
