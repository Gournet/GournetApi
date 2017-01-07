class Api::V1::ChefsController < ApplicationController
  include ControllerUtility
  before_action :set_pagination, only: [:index,:chefs_by_ids,:chefs_by_not_ids,:chefs_with_dishes,
    :chefs_with_followers,:chefs_with_orders,:chefs_with_orders_today,:chefs_with_orders_yesterday,
    :chefs_with_orders_week,:chefs_with_orders_month,:chefs_with_orders_year]
  before_action :set_chef, only: [:show,:destroy,:follow,:unfollow]
  before_action :authenticate_admin!, only: [:destroy]
  before_action :authenticate_user!, only: [:follow,:unfollow]

  def index
    @chefs = Chef.load_chefs(@page,@per_page)
    if stale?(@chefs)
      render json: @chefs,status: :ok
    end
  end

  def show
    if @chef
      if stale?(@chef,public: true)
        render json: @chef,status: :ok
      end
    else
      record_not_found
    end
  end

  def destroy
    if @chef
      @chef.destroy
      if @chef.destroyed?
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def chefs_by_ids
    chef_params_ids
    @chefs = Chef.chefs_by_ids(paramas[:chef][:ids],@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_by_not_ids
    chef_params_ids
    @chefs = Chef.chefs_by_not_ids(params[:chef][:ids],@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs, status: :ok
    end
  end

  def chefs_with_dishes
    @chefs = Chef.chefs_with_dishes(@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_with_followers
    @chefs = Chef.chefs_with_dishes(@page, @per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_with_orders
    @chefs = Chef.chefs_with_orders(@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs, status: :ok
    end
  end

  def chefs_with_orders_today
    @chefs = Chef.chefs_with_orders_today(@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_with_orders_yesterday
    @chefs = Chef.chefs_with_orders_yesterday(@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_with_orders_week
    @chefs = Chef.chefs_with_orders_week(@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_with_orders_month
    @chefs = Chef.chefs_with_orders_month(params[:chef][:year],params[:chef][:month],@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def chefs_with_orders_year
    @chefs = Chef.chefs_with_orders_year(params[:chef][:year],@page,@per_page)
    if stale?(@chefs,public: true)
      render json: @chefs,status: :ok
    end
  end

  def best_seller_chefs_per_month
    chef_params_date
    @chefs = Chef.best_seller_chefs_per_month(params[:chef][:year],params[:chef][:month])
    if stale?(@chefs,public: true)
      render json: @chefs, status: :ok
    end
  end

  def best_seller_chefs_per_year
    chef_params_year
    @chefs = Chef.best_seller_chefs_per_year(params[:chef][:year])
    if stale?(@chefs,public: true)
      render json: @chefs, status: :ok
    end
  end

  def follow
    if @chef
      follower = Follower.new(user_id: current_user.id,chef_id: @chef.id)
      if follower.save
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def unfollow
    if @chef
      follower = Follower.where(user_id: current_user.id).where(chef_id: @chef.id)
      if follower
        follower.destroy
        if follower.destroyed?
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
      @page = params[:page][:number]
      @per_page = params[:page][:size]
      @page ||= 1
      @per_page ||= 10
    end

    def set_chef
      @chef = Chef.chef_by_id(params[:id])
    end

    def chef_params_ids
      params.require(:chef).permit(:ids => [])
    end

    def chef_params_date
      params.require(:chef).permit(:year,:month)
    end

    def chef_params_year
      params.require(:chef).permit(:year)
    end
end
