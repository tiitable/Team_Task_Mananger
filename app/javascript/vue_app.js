import { createApp } from "vue"
import axios from "axios"
import App from "./components/App.vue"

// Configure axios defaults
axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
axios.defaults.headers.common["X-CSRF-Token"] = document.querySelector("meta[name=\"csrf-token\"]")?.getAttribute("content")

// Create Vue app
const app = createApp(App)

// Mount the app
app.mount("#vue-app")
