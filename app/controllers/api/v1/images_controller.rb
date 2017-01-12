class Api::V1::ImagesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update]
  devise_token_auth_group :member, contains: [:chef, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action :set_image, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index]

  def index
    @images = nil
    if params.has_key?(:dish_id)
      @images = Image.images_by_dish_id(params[:dish_id],@page,@per_page)
    else
      @images = Image.load_images(@page,@per_page)
    end
    render json: @images, status: :ok

  end

  def show
    if @image
      if stale?(@image,public: true)
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
      render json: @image, status: :created, :location => api_v1_image_path(@image)
    else
      record_errors(@image)
    end
  end

  def update
    if @image
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef == current_chef.id
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
      if chef == current_member.id || current_member.is_a?(Admin)
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
      if params.has_key?(:page)
        @page = params[:page][:number].to_i
        @per_page = params[:page][:size].to_i
      end
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
