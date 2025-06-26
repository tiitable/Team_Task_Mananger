Rails.application.routes.draw do
  devise_for :users
  root 'posts#index'

  resources :posts, only: [:new, :create, :show, :destroy]
  resources :tasks

  # API Routes
  namespace :api do
    # Authentication routes
    post 'auth/sign_up', to: 'auth#sign_up'
    post 'auth/sign_in', to: 'auth#sign_in'
    delete 'auth/sign_out', to: 'auth#sign_out'
    get 'auth/me', to: 'auth#current_user_info'
    patch 'auth/profile', to: 'auth#update_profile'
    
    # Work Groups (Workspaces) routes
    resources :work_groups do
      member do
        post :add_user
        delete :remove_user
      end
      
      # Tasks nested under work groups
      resources :tasks, except: [:new, :edit]
    end
    
    # Additional workspace routes
    get 'my_workspaces', to: 'work_groups#my_workspaces'
    
    # Additional task routes
    get 'my_tasks', to: 'tasks#my_tasks'
    get 'dashboard_stats', to: 'tasks#dashboard_stats'
    post 'tasks', to: 'tasks#create'  # Create task without work group
    
    # Task user assignment
    resources :tasks, only: [] do
      member do
        post :assign_users
        delete 'unassign_user/:user_id', to: 'tasks#unassign_user', as: :unassign_user
      end
    end
  end
end