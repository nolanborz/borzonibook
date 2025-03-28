Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  namespace :users do
    get "oauth_invitation/new", to: "oauth_invitations#new", as: :new_oauth_invitation
    post "oauth_invitation", to: "oauth_invitations#create", as: :oauth_invitation
  end
  resources :posts do
    resources :comments
    resources :likes, only: [ :create, :destroy ]
    resources :dislikes, only: [ :create, :destroy ]
  end
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :relationships, only: [ :create, :destroy ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  resources :profiles, only: [ :show ]
  root "home#index"
end
