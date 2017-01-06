Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    namespace :v1 do

      controller :facebook do
        post 'loginFacebook', to: "facebook#create_facebook_account"
      end
      concern :ordered do
        resources :orders, only: [:index,:show]
      end

      resources :users,concerns: :ordered, :only => [:index,:show] do
        resources :addresses
        resources :comments, except: [:create]
      end

      resources :admins, :only => [:index,:show] do
        resources :orders, only: [:destroy,:index,:show]
      end

      resources :chefs,concerns: :ordered, :only => [:index,:show] do
        resources :dishes, :only => [:create,:update,:destroy]
      end

      resources :dishes, concerns: :ordered, :only => [:index,:show] do
        resources :availabilities
        resources :comments
        resources :images
      end

      scope "/admin" do
        resources :alergies
        resources :categories
      end
      resources :orders, :only => [:show,:create,:index]

    end
  end
  mount_devise_token_auth_for 'Admin', at: '/api/v1/admin_auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'User', at: '/api/v1/auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'Chef', at: '/api/v1/chef_auth', skip: [:omniauth_callbacks]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
