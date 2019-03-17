# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, path: '', defaults: { format: :json } do
    namespace :v1 do
      post 'sign_up' => 'registrations#create'
      post 'sign_in' => 'sessions#create'
      get 'me' => 'profile#show'
      patch 'me' => 'profile#update'

      resources :recipes do
        collection do
          get :community
        end
        member do
          post :like
          delete 'like' => 'recipes#unlike'
        end
      end
    end
  end
end
