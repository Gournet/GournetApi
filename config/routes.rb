Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    namespace :v1 do

      controller :facebook do
        post 'loginFacebook', to: "facebook#create_facebook_account"
      end
      concern :ordered do
        resources :orders, only: [:index,:show]
      end
      resources :iamges, :only => [:index]
      resources :users,concerns: :ordered, :only => [:index,:show,:destroy] do
        resources :addresses do
          collection do
            get 'popularAddressesUser', to: "addresses#popular_addresses"
            get 'addressesByLatLng', to: "addresses#find_adddress_by_lat_and_lng"
            get 'addressesByOrders', to: "addresses#addresses_with_orders"
          end
        end
        resources :comments, except: [:create] do
          collection do
            get 'commentsByUser', to: "comments#comments_by_user"
          end

        end
      end

      resources :admins, :only => [:index,:show,:destory] do
        collection do
          get 'adminsByIds', to: "admins#admins_by_ids"
          get 'adminsByNotIds', to: "admins#admins_by_not_ids"
          get 'adminByUsername', to: "admins#admin_by_username"
          get 'adminByEmail', to: "admmins#admin_by_email"
          get 'adminsBySearch', to: "admins#admins_by_search"
        end
        resources :orders, only: [:destroy,:index,:show]
      end

      resources :chefs,concerns: :ordered, :only => [:index,:show,:destroy] do
        collection do
          get 'chefsByIds', to: "chefs#chefs_by_ids"
          get 'chefsByNotIds', to: "chefs#chefs_by_not_ids"
          get 'chefsWithDishes', to: "chefs#chefs_with_dishes"
          get 'chefsWithFollowers', to: "chefs#chefs_with_followers"
          get 'chefsWithOrders', to: "chefs#chefs_with_orders"
          get 'chefsWithOrdersToday', to: "chefs#chefs_with_orders_today"
          get 'chefsWithOrdersYesterday', to: "chefs#chefs_with_orders_yesterday"
          get 'chefsWithOrdersWeek', to: "chefs#chefs_with_orders_week"
          get 'chefsWithOrdersMonth', to: "chefs#chefs_with_orders_month"
          get 'chefsWithOrdersYear', to: "chefs#chefs_with_orders_year"
          get 'bestSellerChefsMonth', to: "chefs#best_seller_chefs_per_month"
          get 'bestSellerChefsYear', to: "chefs#best_seller_chefs_per_year"
        end
        member do
          match 'follow', to: "chefs#follow", via: [:post,:put,:patch]
          match 'unfollow', to: "chefs#unfollow", via: [:delete]
        end
        resources :dishes, :only => [:create,:update,:destroy]
      end
      resources :availabilities, :only => [:index] do
        collection do
          get 'today', to: "availabilities#today"
          get 'tomorrow', to: "availabilities#tomorrow"
          get 'nextSevenDasy', to: "availabilities#next_seven_days"
          get 'todayCount', to: "availabilities#today_with_count"
          get 'tomorrowCount', to: "availabilities#tomorrow_with_count"
        end
      end
      resources :dishes, concerns: :ordered, :only => [:index,:show] do
        collection do
          get 'dishesByIds', to: "dishes#dishes_by_ids"
          get 'dishesByNotIds', to: "dishes#dishes_by_not_ids"
          get 'popularDishesByRatingGratherThan', to: "dishes#popular_dishes_by_rating_grather_than"
          get 'dishesByPrice', to: "dishes#dishes_by_price"
          get 'dishesByCalories', to: "dishes#dishes_by_calories"
          get 'dishesByCookingTime', to: "dishes#dishes_by_cooking_time"
          get 'dishesByRating', to: "dishes#dishes_by_rating"
          get 'dishesWithRating', to: "dishes#dishes_with_rating"
          get 'dishesWithComments', to: "dishes#dishes_with_comments"
          get 'dishesWithRatingAndComments', to: "dishes#dishes_with_rating_and_comments"
          get 'dishesWithOrders', to: "dishes#dishes_with_orders"
          get 'dishesOrdersToday', to: "dishes#dishes_by_orders_today"
          get 'dishesOrdersYesterday', to: "dishes#dishes_by_orders_yesterday"
          get 'dishesOrdersWeek', to: "dishes#dishes_by_orders_week"
          get 'dishesOrdersMonth', to: "dishes#dishes_by_orders_month"
          get 'dishesOrdersYear', to: "dishes#dishes_by_orders_year"
          get 'bestSellerDishesMonth', to: "dishes#best_seller_dishes_per_month"
          get 'bestSellerDishesYear', to: "dishes#best_seller_dishes_per_year"
        end
        member do
          match 'addRating', to: "dishes#add_rating_dish", via: [:post,:put,:patch]
          match 'removeRating', to: "dishes#remove_rating_dish", via: [:delete]
          match 'addFavorite', to: "dishes#add_favorite_dish", via: [:post,:put,:patch]
          match 'removeFavorite', to: "dishes#remove_favorite_dish", via: [:delete]
        end
        resources :availabilities do
          collection do
            get 'availabilitiesByDish', to: "availabilities#availabilities_by_dish"
          end
        end
        resources :comments do
          collection do
            get 'commentsByDish', to: "comments#comments_by_dish"
            get 'commentsWithVotesByDish', to: "comments#comments_with_votes_by_dish"
          end
        end
        resources :images
      end

      scope "/admins" do
        resources :alergies do
          collection do
            get 'alergiesByIds', to: "alergies#alergies_by_ids"
            get 'alergiesByNotIds', to: "alergies#alergies_by_not_ids"
            get 'alergiesWithUsers', to: "alergies#alergies_with_users"
            get 'alergiesWithDishes', to: "alergies#alergies_with_dishes"
            get 'alergiesWithDishesAndUsers', to: "alergies#alergies_with_dishes_and_users"
            get 'alergiesBySearch', to: "alergies#alergies_by_search"
          end
        end
        resources :categories do
          collection do
            get 'categoriesByIds', to: "categories#categories_by_ids"
            get 'categoriesByNotIds', to: "categories#categories_by_not_ids"
            get 'categoriesWithDishes', to: "categories#categories_with_dishes"
            get 'categoriesBySearch', to: "categories#categories_by_search"
          end
        end
      end
      resources :orders, :only => [:show,:create,:index]
      resources :comments, :only => [:show,:index] do
        member do
          match 'addVote', to: "comments#add_vote", via: [:post,:put,:patch]
        end
      end
    end

  end
  mount_devise_token_auth_for 'Admin', at: '/api/v1/admin_auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'User', at: '/api/v1/auth', skip: [:omniauth_callbacks]

  mount_devise_token_auth_for 'Chef', at: '/api/v1/chef_auth', skip: [:omniauth_callbacks]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
