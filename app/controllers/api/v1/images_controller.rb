class Api::V1::ImagesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef, only: [:create,:update,:destroy]
  before_action :set_image, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index]

  def index
    render json: Images.images_from_dish(params[:dish_id],@page,@per_page), status: :ok
  end

  def show
    if @image
      if stale?(last_modified: @image.updated_at)
        render json: @image,status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @image = Image.new(image_params)
    @image.dish_id = params[:dish_id]
    if @image.save
      render json: @image, status: :ok
    else
      record_errors(@image)
    end
  end

  def update
    if @image
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef.id == current_chef.id
        if @image.update(image_params)
          render json: @image, status: :ok
        else
          record_errors(@image)
        end
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def destroy
    if @image
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef.id == current_chef.id
        @image.destroy
        if @image.destroyed?
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

    def image_params
      params.require(:image).permit(:image,:order,:description)
    end

    def set_image
      @image =  Image.image_by_id(params[:id])
    end

end
