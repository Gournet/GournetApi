class Api::V1::ImagesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update]
  devise_token_auth_group :member, contains: [:chef, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action :set_image, only: [:show,:update,:destroy]
  before_action only: [:index] do
    set_pagination(params)
  end
  before_action do
    set_include(params)
  end

  def index
    @images = nil
    if params.has_key?(:dish_id)
      @images = params.has_key?(:sort) ? Image.unscoped.images_by_dish_id(params[:dish_id],@page,@per_page) : Image.images_by_dish_id(params[:dish_id],@page,@per_page)
    else
      @images = params.has_key?(:sort) ? Image.unscoped.load_images(@page,@per_page) : Image.load_images(@page,@per_page)
    end
    @images = set_orders(params,@images)
    render json: @images, status: :ok, include: @include,root: "data",meta: meta_attributes(@images)

  end

  def show
    if @image
      if stale?(@image,public: true)
        render json: @image,status: :ok, include: @include,root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @image = Image.new(image_params)
    @image.dish_id = params[:dish_id]
    if @image.save
      render json: @image, status: :created, serializer: AttributesImageSerializer, status_method: "Created", :location => api_v1_image_path(@image),root: "data"
    else
      record_errors(@image)
    end
  end

  def update
    if @image
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef == current_chef.id
        if @image.update(image_params)
          render json: @image, status: :ok, serializer: AttributesImageSerializer, status_method: "Updated",root: "data"
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

    def image_params
      params.require(:image).permit(:image,:order,:description)
    end

    def set_image
      @image =  Image.image_by_id(params[:id])
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "order", "-order"
          query = query.order_by_order(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
    end

end
