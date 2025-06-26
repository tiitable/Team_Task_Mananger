import { createApp } from 'vue'
import App from '@/App.vue'
import { registerPlugins } from '@core/utils/plugins'
import { useUserStore } from '@/stores/user'

// Styles
import '@core/scss/template/index.scss'
import '@layouts/styles/index.scss'

// Create vue app
const app = createApp(App)

// Register plugins
registerPlugins(app)

// Initialize user store after plugins are registered
app.mount('#app')

// Initialize user state from localStorage after app is mounted
const userStore = useUserStore()
userStore.initializeUser()
