class Api::V1::UsersController < ApplicationController
  include ControllerUtility
  before_action :set_pagination, only: [:index,:users_by_ids,:users_by_not_ids,:orders_today,:orders_yesterday,:orders_week,:orders_month,:orders_year,:users_with_addresses,:users_with_alergies,:users_with_orders,:users_with_favorite_dishes,:users_with_rating_dishes,:search]
  before_action :set_user, only: [:show,:destroy]
  before_action :authenticate_admin!, only: [:destroy]
  before_action :set_include

  def index
    @users =  params.has_key?(:sort) ? User.unscoped.load_users(@page,@per_page) : User.load_users(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def show
    if @user
      if stale?(@user,public: true)
        render json: @user, status: :ok, include: @include,root: "data"
      end
    else
      render json: { data: {
        status: "Error",
        error: "We can't find a valid record"
      }
    }, status: :not_found
    end
  end

  def destroy
    if @user
      @user.destroy
      if @user.destroyed?
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def search
    @users = params.has_key?(:sort) ? User.unscoped.search(params[:user][:text],@page,@per_page) : User.search(params[:user][:text],@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def users_by_ids
    @users = params.has_key?(:sort) ? User.unscoped.users_by_ids(params[:user][:ids],@page,@per_page) : User.users_by_ids(params[:user][:ids],@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def users_by_not_ids
    @users = params.has_key?(:sort) ? User.unscoped.users_by_not_ids(params[:user][:ids],@page,@per_page) : User.users_by_not_ids(params[:user][:ids],@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def orders_today
    @users = params.has_key?(:sort) ? User.unscoped.orders_today(@page,@per_page) : User.orders_today(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def orders_today_user
    @user = User.orders_today_user(params[:id])
    render json: @user, status: :ok, include: @include,root: "data"
  end

  def orders_yesterday
    @users = params.has_key?(:sort) ? User.unscoped.orders_yesterday(@page,@per_page) : User.orders_yesterday(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def orders_yesterday_user
    @user = User.orders_yesterday_user(params[:id])
    render json: @user, status: :ok, include: @include,root: "data"
  end

  def orders_week
    @users = params.has_key?(:sort) ? User.unscoped.orders_week(@page,@per_page) : User.orders_week(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def orders_week_user
    @user = User.orders_week_user(params[:id])
    render json: @user, status: :ok, include: @include,root: "data"
  end

  def orders_month
    @users = params.has_key?(:sort) ? User.unscoped.orders_month(params[:user][:year].to_i,params[:user][:month].to_i,@page,@per_page) : User.orders_month(params[:user][:year].to_i,params[:user][:month].to_i,@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def orders_month_user
    @user = User.orders_month_user(params[:id],params[:user][:year].to_i,params[:user][:month].to_i)
    render json: @user, status: :ok, include: @include,root: "data"
  end

  def orders_year
    @users = params.has_key?(:sort) ? User.unscoped.orders_year(params[:user][:year].to_i,@page,@per_page) : User.orders_year(params[:user][:year].to_i,@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, include: @include,root: "data",meta: meta_attributes(@users)
  end

  def orders_year_user
    @user = User.orders_year_user(params[:id],params[:user][:year].to_i)
    render json: @user, status: :ok, include: @include,root: "data"
  end

  def users_with_addresses
    @users = params.has_key?(:sort) ? User.unscoped.users_with_addresses(@page,@per_page) : User.users_with_addresses(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok,root: "data",each_serializer: SimpleUserSerializer,fields: set_fields,meta: meta_attributes(@users)
  end

  def users_with_alergies
    @users = params.has_key?(:sort) ? User.unscoped.users_with_alergies(@page,@per_page) : User.users_with_alergies(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok,root: "data",each_serializer: SimpleUserSerializer,fields: set_fields,meta: meta_attributes(@users)

  end

  def users_with_orders
    @users = params.has_key?(:sort) ? User.unscoped.users_with_orders(@page,@per_page) : User.users_with_orders(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok,root: "data",each_serializer: SimpleUserSerializer,fields: set_fields, meta: meta_attributes(@users)
  end

  def users_with_favorite_dishes
    @users = params.has_key?(:sort) ? User.unscoped.users_with_favorite_dishes(@page,@per_page) : User.users_with_favorite_dishes(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok,root: "data",each_serializer: SimpleUserSerializer,fields: set_fields, meta: meta_attributes(@users)
  end

  def users_with_rating_dishes
    @users = params.has_key?(:sort)? User.unscoped.users_with_rating_dishes(@page,@per_page) : User.users_with_rating_dishes(@page,@per_page)
    @users = set_orders(params,@users)
    render json: @users, status: :ok,root: "data",each_serializer: SimpleUserSerializer,fields: set_fields, meta: meta_attributes(@users)
  end

  def best_seller_users_per_month
    @users = params.has_key?(:sort) ? User.unscoped.best_seller_users_per_month(params[:user][:year].to_i,params[:user][:month].to_i) : User.best_seller_users_per_month(params[:user][:year].to_i,params[:user][:month].to_i)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, each_serializer: SimpleUserSerializer,fields: set_fields,root: "data"
  end

  def best_seller_users_per_year
    @users = params.has_key?(:sort) ? User.unscoped.best_seller_users_per_year(params[:user][:year].to_i) : User.best_seller_users_per_year(params[:user][:year].to_i)
    @users = set_orders(params,@users)
    render json: @users, status: :ok, each_serializer: SimpleUserSerializer,fields: set_fields,root: "data"
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

    def set_fields
      array = params[:fields].split(",") if params.has_key?(:fields)
      array ||= []
      array_s = nil
      if !array.empty?
        array_s = []
      end
      array.each do |a|
        array_s.push(a.to_sym)
      end
      array_s
    end

    def set_user
      @user = User.user_by_id(params[:id])
    end

    def set_orders(params,query)
      if params.has_key?(:sort)
        values = params[:sort].split(",")
        values.each  do |val|
          query = set_order(val,query)
        end
      end
      query
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "email", "-email"
          query = query.order_by_email(ord)
        when "username", "-username"
          query = query.order_by_username(ord)
        when "name", "-name"
          query = query.order_by_name(ord)
        when "lastname", "-lastname"
          query = query.order_by_lastname(ord)
        when "birthday", "-birthday"
          query = query.order_by_birthday(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
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
