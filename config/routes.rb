Rails.application.routes.draw do
  mount_devise_token_auth_for 'Admin', at: 'admin_auth'

  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Chef', at: 'chef_auth'
  as :chef do
    # Define routes for Chef within this block.
  end
  as :user do
    # Define routes for User within this block.
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
