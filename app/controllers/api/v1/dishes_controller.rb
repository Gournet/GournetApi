class Api::V1::DishesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update,:destroy]
  before_action :set_dish, only: [:show.:destroy,:update]
  before_action :set_pagination, only: [:index]

  def index
    render json: Dish.load_dishes(@page,@per_page),status: :ok
  end

  def show
    if @dish
      if stale?(last_modified: @dish.updated_at)
        render json: @dish, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @dish =  Dish.new(dish_params)
    @dish.chef_id = params[:chef_id]
    if @dish.save
      render json: @dish, status: :ok
    else
      record_errors(@dish)
    end
  end

  def update
    if @dish
      if @dish.update(dish_params)
        render json: @dish,status: :ok
      else
        record_errors(@dish)
      end
    else
      record_not_found
    end
  end

  def destroy
    if @dish
      if @dish.chef_id == current_chef.id
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

  private
    def set_pagination
      @page = params[:page][:number]
      @per_page = params[:page][:size]
      @page ||= 1
      @per_page ||= 10
    end
    def set_dish
      @dish = Dish.dish_by_id(params[:id])
    end
    def dish_params
      params.require(:dish).permit(:name,:description,:price,:cooking_time,:calories)
    end

end
