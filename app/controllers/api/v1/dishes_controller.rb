class Api::V1::DishesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update]
  devise_token_auth_group :member, contains: [:chef, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action :authenticate_user!, only: [:add_favorite_dish,:remove_favorite_dish,:add_rating_dish,:remove_rating_dish]
  before_action :set_dish, only: [:show,:destroy,:update,:add_favorite_dish,:remove_favorite_dish,:add_rating_dish,:remove_rating_dish]
  before_action :set_pagination, only: [:index,:dishes_by_ids,:dishes_by_not_ids,:popular_dishes_by_rating_grather_than,:dishes_by_price,
  :dishes_by_calories,:dishes_by_cooking_time,:dishes_by_rating,:dishes_with_rating,:dishes_with_comments,:dishes_with_rating_and_comments,
  :dishes_with_orders,:dishes_with_orders_today,:dishes_with_orders_yesterday,:dishes_with_orders_week,:dishes_with_orders_month,:dishes_with_orders_year]
  before_action :set_include

  def index
    @dishes = nil
    if params.has_key?(:chef_id)
      @dishes =  Dish.dish_by_chef(params[:chef_id],@page,@per_page)
    else
      @dishes =  Dish.load_dishes(@page,@per_page)
    end
    render json: @dishes,status: :ok, include: @include,root: "data"

  end

  def show
    if @dish
      if stale?(@dish,public: true)
        render json: @dish, status: :ok, include: @include,root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @dish =  Dish.new(dish_params)
    @dish.chef_id = current_chef.id
    if @dish.save
      render json: @dish, status: :created, :location => api_v1_dish_path(@dish),root: "data"
    else
      record_errors(@dish)
    end
  end

  def update
    if @dish
      if @dish.chef_id == current_chef.id
        if @dish.update(dish_params)
          render json: @dish,status: :ok,root: "data"
        else
          record_errors(@dish)
        end
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def destroy
    if @dish
      if @dish.chef_id == current_member.id || current_member.is_a?(Admin)
        @dish.destroy
        if @dish.destroyed?
          record_success
        else
          record_error
        end
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def dishes_by_ids
    @dishes = Dish.dishes_by_ids(params[:dish][:ids],@page, @per_page)
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_not_ids
    @dishes = Dish.dishes_by_not_ids(params[:dish][:ids],@page,@per_page)
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def popular_dishes_by_rating_greater_than
    @dishes = Dish.popular_dishes_by_rating(params[:dish][:rating].to_i,@page,@per_page)
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_price
    @dishes = Dish.includes(:images,:chef,:categories,:alergies,:users,:comments,:availabilities,orders: [:user]).all.paginate(:page => @page,:per_page =>@per_page).order_by_price
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_calories
    @dishes = Dish.includes(:images,:chef,:categories,:alergies,:users,:comments,:availabilities,orders: [:user]).all.paginate(:page => @page,:per_page => @per_page).order_by_calories
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_cooking_time
    @dishes = Dish.includes(:images,:chef,:categories,:alergies,:users,:comments,:availabilities,orders: [:user]).all.paginate(:page => @page, :per_page =>@per_page).order_by_cooking_time
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_rating
    @dishes = Dish.includes(:images,:chef,:categories,:alergies,:users,:comments,:availabilities,orders: [:user]).all.paginate(:page => @page,:per_page => @per_page).order_by_rating
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_with_rating
    @dishes = Dish.dishes_with_rating(@page,@per_page)
    render json: @dishes, status: :ok,root: "data"
  end

  def dishes_with_comments
    @dishes = Dish.dishes_with_comments(@page,@per_page)
    render json: @dishes, status: :ok,root: "data"
  end

  def dishes_with_rating_and_comments
    @dishes = Dish.dihses_with_rating_and_comments(@page,@per_page)
    render json: @dishes, status: :ok,root: "data"
  end

  def dishes_with_orders
    @dishes = Dish.dishes_with_orders(@page,@per_page)
    render json: @dishes,status: :ok,root: "data"
  end

  def dishes_by_orders_today
    @dishes = Dish.dishes_by_orders_today(@page,@per_page)
    render json: @dishes,status: :ok, include: @include,root: "data"
  end

  def orders_today
    @dishes = Dish.orders_today(params[:id])
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_yesterday
    @dishes = Dish.dishes_by_orders_yesterday(@page,@per_page)
    render json: @dishes,status: :ok, include: @include,root: "data"
  end

  def orders_yesterday
    @dishes = Dish.orders_yesterday(params[:id])
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_week
    @dishes = Dish.dishes_by_orders_week(@page,@per_page)
    render json: @dishes,status: :ok, include: @include,root: "data"
  end

  def orders_week
    @dishes = Dish.orders_week(params[:id])
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_month
    @dishes = Dish.dishes_by_orders_month(params[:dish][:year].to_i,params[:dish][:month].to_i,@page,@per_page)
    render json: @dishes,status: :ok, include: @include,root: "data"
  end

  def orders_month
    @dishes = Dish.orders_month(params[:id],params[:dish][:year].to_i,params[:dish][:month].to_i)
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_year
    @dishes = Dish.dishes_by_orders_year(params[:dish][:year].to_i,@page,@per_page)
    render json: @dishes, status: :ok, include: @include,root: "data"
  end

  def orders_year
    @dishes = Dish.orders_year(params[:id],params[:dish][:year].to_i)
    render json: @dishes, status: :ok, include: @include,root: "data"

  end

  def best_seller_dishes_per_month
    @dishes = Dish.best_seller_dishes_per_month(params[:dish][:year].to_i,params[:dish][:month].to_i)
    render json: @dishes,status: :ok,root: "data"
  end

  def best_seller_dishes_per_year
    @dishes = Dish.best_seller_dishes_per_year(params[:dish][:year].to_i)
    render json: @dishes,status: :ok,root: "data"
  end

  def add_favorite_dish
    if @dish
      favorite = FavoriteDish.new(user_id: current_user.id,dish_id: @dish.id)
      if FavoriteDish.add_favorite(current_user.id,@dish.id)
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def add_rating_dish
    if @dish
      if rating = RatingDish.add_rating(current_user.id,@dish.id,params[:dish][:rating])
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def remove_favorite_dish
    if @dish
      favorite = FavoriteDish.remove_favorite(current_user.id,@dish.id)
      if favorite
        if favorite.destroyed?
          record_success
        else
          record_error
        end
      else
        record_not_found
      end
    else
      record_not_found
    end
  end

  def remove_rating_dish
    if @dish
      rating = RatingDish.remove_rating(current_user.id,@dish.id)
      if rating
        if rating.destroyed?
          record_success
        else
          record_error
        end
      else
        record_not_found
      end
    else
      record_not_found
    end
  end

  private
    def set_pagination
      if params.has_key?(:page)
        @page = params[:page][:number].to_i
        @per_page = params[:page][:size].to_i
      end
      @page ||= 1
      @per_page ||= 10
    end

    def set_dish
      @dish = Dish.dish_by_id(params[:id])
    end

    def dish_params
      params.require(:dish).permit(:name,:description,:price,:cooking_time,:calories)
    end

    def set_include
      temp = params[:include]
      temp ||= "*"
      if temp.include? "**"
        temp = "*"
      end
      @include = temp
    end


end
