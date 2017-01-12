class Api::V1::UsersController < ApplicationController
  include ControllerUtility
  before_action :set_pagination, only: [:index,:users_by_ids,:users_by_not_ids,:orders_today,:orders_yesterday,:orders_week,:orders_month,:orders_year,:users_with_addresses,:users_with_alergies,:users_with_orders,:users_with_favorite_dishes,:users_with_rating_dishes,:search]
  before_action :set_user, only: [:show,:destroy]
  before_action :authenticate_admin!, only: [:destroy]
  before_action :set_include

  def index
    @users =  User.load_users(@page,@per_page)
    if stale?(@users,public: true)
      render json: @users, status: :ok, include: @include,root: "data"
    end
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
    @users = User.search(params[:user][:text],@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def users_by_ids
    @users = User.users_by_ids(params[:user][:ids],@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def users_by_not_ids
    @users = User.users_by_not_ids(params[:user][:ids],@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_today
    @users = User.orders_today(@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_today_user
    @users = User.orders_today_user(params[:id])
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_yesterday
    @users = User.orders_yesterday(@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_yesterday_user
    @users = User.orders_yesterday_user(params[:id])
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_week
    @users = User.orders_week(@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_week_user
    @users = User.orders_week_user(params[:id])
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_month
    @users = User.orders_month(params[:user][:year].to_i,params[:user][:month].to_i,@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_month_user
    @users = User.orders_month_user(params[:id],params[:user][:year].to_i,params[:user][:month].to_i)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_year
    @users = User.orders_year(params[:user][:year].to_i,@page,@per_page)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def orders_year_user
    @users = User.orders_year_user(params[:id],params[:user][:year].to_i)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def users_with_addresses
    @users = User.users_with_addresses(@page,@per_page)
    render json: @users, status: :ok,root: "data"
  end

  def users_with_alergies
    @users = User.users_with_alergies(@page,@per_page)
    render json: @users, status: :ok,root: "data"

  end

  def users_with_orders
    @users = User.users_with_alergies(@page,@per_page)
    render json: @users, status: :ok,root: "data"
  end

  def users_with_favorite_dishes
    @users = User.users_with_favorite_dishes(@page,@per_page)
    render json: @users, status: :ok,root: "data"
  end

  def users_with_rating_dishes
    @users = User.users_with_rating_dishes(@page,@per_page)
    render json: @users, status: :ok,root: "data"
  end

  def best_seller_users_per_month
    @users = User.best_seller_users_per_month(params[:user][:year].to_i,params[:user][:month].to_i)
    render json: @users, status: :ok, include: @include,root: "data"
  end

  def best_seller_users_per_year
    @users = User.best_seller_users_per_year(params[:user][:year].to_i)
    render json: @users, status: :ok, include: @include,root: "data"
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

    def set_user
      @user = User.user_by_id(params[:id])
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
