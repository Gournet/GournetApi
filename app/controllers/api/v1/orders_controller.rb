class Api::V1::OrdersController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:destroy]
  before_action :set_pagination, only: [:index,:orders_by_ids,:orders_by_not_ids,:orders_today,:orders_yesterday,:orders_week,:orders_month,:orders_year,:orders_today_resource,:orders_yesterday_resource,:orders_week_resource,:orders_month_resource,:orders_year_resource]
  before_action :set_order, only: [:show]
  before_action :authenticate_user!, only: [:create]

  def index
    @orders = nil
    if params.has_key?(:user_id)
      @orders = Order.orders_by_user_id(params[:user_id],@page,@per_page)

    elsif params.has_key?(:chef_id)
      @orders =  Order.orders_by_chef_id(params[:chef_id],@page,@per_page)

    elsif params.has_key?(:dish_id)
      @orders = Order.orders_by_dish_id(params[:dish_id],@page,@per_page)
    else
      @orders = Order.load_orders(@page,@per_page)
    end
    render json: @orders,status: :ok
  end

  def show
    if @order
      if stale?(@order,public: true)
        render json: @order, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    order_params
    @order = Order.new()
    @order.count = params[:order][:count].to_i
    @order.day = params[:order][:day]
    @order.price = params[:order][:price]
    @order.comment = params[:order][:comment]
    @order.estimated_time = params[:order][:estimated_time]
    @order.payment_type = Order.payment_types[params[:order][:payment_type]]
    user = Address.find_by_id(params[:relationship][:address_id]).user.id
    if user ==  current_user.id
      @order.address_id = params[:relationship][:address_id]
      @order.user_id = current_user.id
      dish = Dish.find_by_id(params[:relationship][:dish_id])
      available = Availability.availabilities_by_dish(dish.id).where(day: params[:order][:day]).first
      if available && available.count >= @order.count
        chef = dish.chef.id
        if chef == params[:relationship][:chef_id]
          @order.dish_id = dish.id
          @order.chef_id =  chef
          available.count = available.count - @order.count
          available.save
          if @order.save
            render json: @order,status: :created, :location => api_v1_order_path(@order)
          else
            record_errors(@order)
          end
        else
          order_dish_errors
        end
      else
        order_quantity_errors
      end
    else
      order_errors
    end
  end

  def destroy
    if @order
      @order.destroy
      if @order.destroyed?
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def orders_by_ids
    @orders = Order.orders_by_ids(params[:order][:ids],@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_by_not_ids
    @orders = Order.orders_by_not_ids(params[:order][:ids],@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_today
    @orders = Order.orders_today(@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_today_resource
    @orders = nil
    if params.has_key?(:user_id)
      @orders = Order.orders_today_user(params[:user_id],@page,@per_page)
    elsif params.has_key?(:chef_id)
      @orders = Order.orders_today_chef(params[:chef_id],@page,@per_page)
    elsif params.has_key?(:dish_id)
      @orders = Order.orders_today_dish(params[:dish_id],@page,@per_page)
    end
    render json: @orders, status: :ok
  end

  def orders_yesterday
    @orders = Order.orders_today(@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_yesterday_resource
    @orders = nil
    if params.has_key?(:user_id)
      @orders = Order.orders_yesterday_user(params[:user_id],@page,@per_page)
    elsif params.has_key?(:chef_id)
      @orders = Order.orders_yesterday_chef(params[:chef_id],@page,@per_page)
    elsif params.has_key?(:dish_id)
      @orders = Order.orders_yesterday_dish(params[:dish_id],@page,@per_page)
    end
    render json: @orders, status: :ok
  end

  def orders_week
    @orders = Order.orders_week(@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_week_resource
    @orders = nil
    if params.has_key?(:user_id)
      @orders = Order.orders_week_user(params[:user_id],@page,@per_page)
    elsif params.has_key?(:chef_id)
      @orders = Order.orders_week_chef(params[:chef_id],@page,@per_page)
    elsif params.has_key?(:dish_id)
      @orders = Order.orders_week_dish(params[:dish_id],@page,@per_page)
    end
    render json: @orders, status: :ok
  end

  def orders_month
    @orders = Order.orders_month(params[:order][:year].to_i,params[:order][:month].to_i,@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_month_resource
    @orders = nil
    if params.has_key?(:user_id)
      @orders = Order.orders_month_user(params[:user_id],params[:order][:year].to_i,params[:order][:month].to_i,@page,@per_page)
    elsif params.has_key?(:chef_id)
      @orders = Order.orders_month_chef(params[:chef_id],params[:order][:year].to_i,params[:order][:month].to_i,@page,@per_page)
    elsif params.has_key?(:dish_id)
      @orders = Order.orders_month_dish(params[:dish_id],params[:order][:year].to_i,params[:order][:month].to_i,@page,@per_page)
    end
    render json: @orders, status: :ok
  end

  def orders_year
    @orders = Order.orders_year(params[:order][:year].to_i,@page,@per_page)
    render json: @orders, status: :ok
  end

  def orders_year_resource
    @orders = nil
    if params.has_key?(:user_id)
      @orders = Order.orders_year_user(params[:user_id],params[:order][:year].to_i,@page,@per_page)
    elsif params.has_key?(:chef_id)
      @orders = Order.orders_year_chef(params[:chef_id],params[:order][:year].to_i,@page,@per_page)
    elsif params.has_key?(:dish_id)
      @orders = Order.orders_year_dish(params[:dish_id],params[:order][:year].to_i,@page,@per_page)
    end
    render json: @orders, status: :ok
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

    def set_order
      @order = Order.order_by_id(params[:id])
    end

    def order_params
      params.require(:order).permit(:count,:price,:comment,:day,:estimated_time,:payment_type)
      params.require(:relationship).permit(:address_id,:chef_id,:dish_id)
    end

end
