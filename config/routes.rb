Rails.application.routes.draw do
  namespace :api  do
    namespace :v1 do
      controller :facebook do
        post 'loginFacebook', to: "facebook#create_facebook_account" 
      end
    end
  end
  mount_devise_token_auth_for 'Admin', at: '/api/v1/admin_auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'User', at: '/api/v1/auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'Chef', at: '/api/v1/chef_auth', skip: [:omniauth_callbacks]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
