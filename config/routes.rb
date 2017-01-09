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

      resources :addresses, :only => [:index,:create,:update,:destroy,:show] do
        collection do
          get 'addressesByLatLng', to: "addresses#find_adddress_by_lat_and_lng"
          get 'addressesWithOrders', to: "addresses#addresses_with_orders"
        end
      end

      resources :users,concerns: :ordered, :only => [:index,:show,:destroy] do
        collection do
          get 'search', to: "users#search"
          post 'usersByIds', to: "users#users_by_ids"
          post 'usersByNotIds', to: "users#users_by_not_ids"
          get 'ordersToday', to: "users#orders_today"
          get 'ordersYesterday', to: "users#orders_yesterday"
          get 'ordersWeek', to: "users#orders_week"
          get 'ordersMonth', to: "users#orders_month"
          get 'ordersYear', to: "users#orders_year"
          get 'usersWithAddresses', to: "users#users_with_addresses"
          get 'usersWithAlergies', to: "users#users_with_alergies"
          get 'usersWithOrders', to: "users#users_with_orders"
          get 'usersWithFavoriteDishes', to: "users#users_with_favorite_dishes"
          get 'usersWithRatingDishes', to: "users#users_with_rating_dishes"
          get 'bestSellerUserMonth', to: "users#best_seller_users_per_month"
          get 'bestSellerUsersYear', to: "users#best_seller_users_per_year"
        end
        member do
          get 'ordersToday', to: "users#orders_today_user"
          get 'ordersYesterday', to: "users#orders_yesterday_user"
          get 'ordersWeek', to: "users#orders_week_user"
          get 'ordersMonth', to: "users#orders_month_user"
          get 'ordersYear', to: "users#orders_year_user"
        end
        resources :addresses, only: [:index,:show] do
          collection do
            get 'popularAddressesUser', to: "addresses#popular_addresses"
          end
        end
        resources :comments, except: [:create] do
          collection do
            get 'commentsByUser', to: "comments#comments_by_user"
          end

        end
      end

      resources :admins, :only => [:index,:show,:destroy] do
        collection do
          post 'adminsByIds', to: "admins#admins_by_ids"
          post 'adminsByNotIds', to: "admins#admins_by_not_ids"
          get 'adminByUsername', to: "admins#admin_by_username"
          get 'adminByEmail', to: "admins#admin_by_email"
          get 'adminsBySearch', to: "admins#admins_by_search"
        end
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
        resources :dishes, :only => [:index,:show]
      end
      resources :availabilities, :only => [:index,:show] do
        collection do
          get 'today', to: "availabilities#today"
          get 'tomorrow', to: "availabilities#tomorrow"
          get 'nextSevenDays', to: "availabilities#next_seven_days"
          get 'todayCount', to: "availabilities#today_with_count"
          get 'tomorrowCount', to: "availabilities#tomorrow_with_count"
        end
      end
      resources :dishes, concerns: :ordered do
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
        resources :availabilities
        resources :comments do
          collection do
            get 'commentsByDish', to: "comments#comments_by_dish"
            get 'commentsWithVotesByDish', to: "comments#comments_with_votes_by_dish"
          end
        end
        resources :images
      end

      scope "/administrator" do
        resources :alergies do
          collection do
            post 'alergiesByIds', to: "alergies#alergies_by_ids"
            post 'alergiesByNotIds', to: "alergies#alergies_by_not_ids"
            get 'alergiesWithUsers', to: "alergies#alergies_with_users"
            get 'alergiesWithDishes', to: "alergies#alergies_with_dishes"
            get 'alergiesWithDishesAndUsers', to: "alergies#alergies_with_dishes_and_users"
            get 'alergiesBySearch', to: "alergies#alergies_by_search"
          end
        end
        resources :categories do
          collection do
            post 'categoriesByIds', to: "categories#categories_by_ids"
            post 'categoriesByNotIds', to: "categories#categories_by_not_ids"
            get 'categoriesWithDishes', to: "categories#categories_with_dishes"
            get 'categoriesBySearch', to: "categories#categories_by_search"
          end
        end
      end
      resources :orders, :only => [:show,:create,:index,:destroy] do
        collection do
          get 'ordersByIds', to: "orders#orders_by_ids"
          get 'ordersByNotIds',to: "orders#orders_by_not_ids"
          get 'ordersToday', to: "orders#orders_today"
          get 'ordersYesterday', to: "orders#orders_yesterday"
          get 'ordersWeek', to: "orders#orders_week"
          get 'ordersMonth', to: "ordders#orders_month"
          get 'ordersYear', to: "orders#orders_year"
        end
      end
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
