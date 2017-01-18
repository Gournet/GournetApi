class Api::V1::DishesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update]
  devise_token_auth_group :member, contains: [:chef, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action :authenticate_user!, only: [:can_make_operation,:add_favorite_dish,:remove_favorite_dish,:add_rating_dish,:remove_rating_dish]
  before_action :set_dish, only: [:can_make_operation,:show,:destroy,:update,:add_favorite_dish,:remove_favorite_dish,:add_rating_dish,:remove_rating_dish]
  before_action only: [:index,:dishes_by_ids,:dishes_by_not_ids,:popular_dishes_by_rating_grather_than,:dishes_with_rating,:dishes_with_comments,:dishes_with_rating_and_comments,
  :dishes_with_orders,:dishes_with_orders_today,:dishes_with_orders_yesterday,:dishes_with_orders_week,:dishes_with_orders_month,:dishes_with_orders_year] do
    set_pagination(params)
  end
  before_action do
    set_include(params)
  end

  def index
    @dishes = nil
    if params.has_key?(:chef_id)
      @dishes =  params.has_key?(:sort) ? Dish.unscoped.dish_by_chef(params[:chef_id],@page,@per_page) : Dish.dish_by_chef(params[:chef_id],@page,@per_page)
    else
      @dishes =  Dish.load_dishes(@page,@per_page)
    end
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok, include: @include,root: "data",meta: meta_attributes(@dishes)
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
      render json: @dish, status: :created, status_method: "Created", serializer: AttributesDishSerializer, :location => api_v1_dish_path(@dish),root: "data"
    else
      record_errors(@dish)
    end
  end

  def update
    if @dish
      if @dish.chef_id == current_chef.id
        if @dish.update(dish_params)
          render json: @dish,status: :ok, status_method: "Updated", serializer: AttributesDishSerializer, root: "data"
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
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_ids(params[:dish][:ids],@page, @per_page) : Dish.dishes_by_ids(params[:dish][:ids],@page, @per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, include: @include,root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_by_not_ids
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_not_ids(params[:dish][:ids],@page,@per_page) : Dish.dishes_by_not_ids(params[:dish][:ids],@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, include: @include,root: "data",meta: meta_attributes(@dishes)
  end

  def popular_dishes_by_rating_greater_than
    @dishes = params.has_key?(:sort) ? Dish.unscoped.popular_dishes_by_rating(params[:dish][:rating].to_i,@page,@per_page) : Dish.popular_dishes_by_rating(params[:dish][:rating].to_i,@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, include: @include,root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_with_rating
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_with_rating(@page,@per_page) : Dish.dishes_with_rating(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, each_serializer: SimpleDishSerializer, fields: set_fields(params),root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_with_comments
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_with_comments(@page,@per_page) : Dish.dishes_with_comments(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, each_serializer: SimpleDishSerializer, fields: set_fields(params), root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_with_rating_and_comments
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dihses_with_rating_and_comments(@page,@per_page) : Dish.dihses_with_rating_and_comments(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, each_serializer: SimpleDishSerializer, fields: set_fields(params), root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_with_orders
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_with_orders(@page,@per_page) : Dish.dishes_with_orders(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok,each_serializer: SimpleDishSerializer, fields: set_fields(params), root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_by_orders_today
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_orders_today(@page,@per_page) : Dish.dishes_by_orders_today(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok, fields: set_fields(params), each_serializer: SimpleDishSerializer,root: "data",meta: meta_attributes(@dishes)
  end

  def orders_today
    @dish = Dish.orders_today(params[:id])
    render json: @dish, status: :ok, include: @include,root: "data",meta: meta_attributes(@dishes)
  end

  def dishes_by_orders_yesterday
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_orders_yesterday(@page,@per_page) : Dish.dishes_by_orders_yesterday(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok, fields: set_fields(params), each_serializer: SimpleDishSerializer,root: "data",meta: meta_attributes(@dishes)
  end

  def orders_yesterday
    @dish = Dish.orders_yesterday(params[:id])
    render json: @dish, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_week
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_orders_week(@page,@per_page) : Dish.dishes_by_orders_week(@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok, fields: set_fields(params), each_serializer: SimpleDishSerializer,root: "data",meta: meta_attributes(@dishes)
  end

  def orders_week
    @dish = Dish.orders_week(params[:id])
    render json: @dish, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_month
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_orders_month(params[:dish][:year].to_i,params[:dish][:month].to_i,@page,@per_page) : Dish.dishes_by_orders_month(params[:dish][:year].to_i,params[:dish][:month].to_i,@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok, fields: set_fields(params), each_serializer: SimpleDishSerializer,root: "data",meta: meta_attributes(@dishes)
  end

  def orders_month
    @dish= Dish.orders_month(params[:id],params[:dish][:year].to_i,params[:dish][:month].to_i)
    render json: @dish, status: :ok, include: @include,root: "data"
  end

  def dishes_by_orders_year
    @dishes = params.has_key?(:sort) ? Dish.unscoped.dishes_by_orders_year(params[:dish][:year].to_i,@page,@per_page) : Dish.dishes_by_orders_year(params[:dish][:year].to_i,@page,@per_page)
    @dishes = set_orders(params,@dishes)
    render json: @dishes, status: :ok, fields: set_fields(params), each_serializer: SimpleDishSerializer,root: "data",meta: meta_attributes(@dishes)
  end

  def orders_year
    @dish = Dish.orders_year(params[:id],params[:dish][:year].to_i)
    render json: @dish, status: :ok, include: @include,root: "data"

  end

  def best_seller_dishes_per_month
    @dishes = params.has_key?(:sort) ? Dish.unscoped.best_seller_dishes_per_month(params[:dish][:year].to_i,params[:dish][:month].to_i) : Dish.best_seller_dishes_per_month(params[:dish][:year].to_i,params[:dish][:month].to_i)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok,root: "data",each_serializer: SimpleDishSerializer, fields: set_fields(params)
  end

  def best_seller_dishes_per_year
    @dishes = params.has_key?(:sort) ? Dish.unscoped.best_seller_dishes_per_year(params[:dish][:year].to_i) : Dish.best_seller_dishes_per_year(params[:dish][:year].to_i)
    @dishes = set_orders(params,@dishes)
    render json: @dishes,status: :ok,root: "data",each_serializer: SimpleDishSerializer, fields: set_fields(params)
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

  def can_make_operation
    if @dish
      @order = Order.where(dish_id: @dish.id).where(user_id: current_user.id).first
      if @order || @order.day > Date.today
        can_operation
      else
        cannot_operation
      end
    else
      record_not_found
    end
  end

  def add_rating_dish
    if @dish
      @order = Order.where(dish_id: @dish.id).where(user_id: current_user.id).first
      if @order || @order.day > Date.today
        if rating = RatingDish.add_rating(current_user.id,@dish.id,params[:dish][:rating])
          record_success
        else
          record_error
        end
      else
        record_add_rating
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

    def set_dish
      @dish = Dish.dish_by_id(params[:id])
    end

    def dish_params
      params.require(:dish).permit(:name,:description,:price,:cooking_time,:calories)
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "name", "-name"
          query = query.order_by_name(ord)
        when "price", "-price"
          query = query.order_by_price(ord)
        when "calories", "-calories"
          query =  query.order_by_calories(ord)
        when "cooking_time", "-cooking_time"
          query = query.order_by_cooking_time(ord)
        when "rating", "rating"
          query = query.order_by_rating(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
    end

end
