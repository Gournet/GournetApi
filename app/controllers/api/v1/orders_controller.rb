class Api::V1::OrdersController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:destroy]
  before_action :set_pagination, only: [:index]
  before_action :set_order, only: [:show]
  before_action :authenticate_user!, only: [:create]

  def index
    if params.has_key?(:user_id)
      render json: Order.orders_by_user_id(params[:user_id],@page,@per_page), status: :ok
    elsif params.has_key?(:chef_id)
      render json: Order.orders_by_chef_id(params[:chef_id],@page,@per_page),status: :ok
    elsif params.has_key?(:dish_id)
      render json: Order.orders_by_dish_id(params[:dish_id],@page,@per_page),status: :ok
    else
      render json: Order.load_orders(@page,@per_page)
    end

  end

  def show
    if @order
      render json: @order, status: :ok
    else
      record_not_found
    end
  end

  def create
    @order = Order.new(order_params)
    user = Address.find_by_id(params[:relationsip][:address_id]).user.id
    if user ==  current_user.id
      @order.address_id = params[:relationship][:address_id]
      @order.user_id = current_user.id
      dish = Dish.find_by_id(params[:relationship][:dish_id])
      available = Availability.today.availabilities_by_dish(dish.id).first
      if available && available.count >= @order.count
        chef = dish.chef.id
        if chef == params[:relationsip][:chef_id]
          @order.dish_id = dish.id
          @order.chef_id =  chef
          available.count = available.count - @order.count
          available.save
          if @order.save
            render json: @order,status: :ok
          else
            record_errors(@order)
          end
        else
          order_dish_errors
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

  private
    def set_pagination
      @page = params[:page][:number]
      @per_page = params[:page][:size]
      @page ||= 1
      @per_page ||= 10
    end

    def set_order
      @order = Order.order_by_id(params[:id])
    end

    def order_params
      params.require(:order).permit(:count,:price,:comment)
      params.require(:relationship).permit(:address_id,:chef_id,:dish_id)
    end

end
