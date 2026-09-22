# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root to: 'tasks#index'
  resources :tasks do
    member do
      patch 'finished'
    end
  end
  resources :teams, only: %i[index show new create edit update] do
    resources :team_members, only: %i[new create edit update] do
      member do
        patch 'deactivate'
      end
    end
  end
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get    'login',   to: 'sessions#new'
  post   'login',   to: 'sessions#create'
  delete 'logout',  to: 'sessions#destroy'
  get 'users', to: 'users#new'
  post 'users', to: 'users#create'

  namespace :admin do
    namespace :documentations do
      resource :erd, only: :show, format: 'html'
    end
  end
end
