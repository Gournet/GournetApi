class Api::V1::CategoriesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :set_category, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index]

  def index
    render json: Category.load_categories(@page,@per_page)
  end

  def show
    if @category
      if stale?(last_modified: @category.updated_at)
        render json: @category, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category,status: :ok
    else
      record_errors(@category)
    end
  end

  def update
    if @category
      if @category.update(category_params)
        render json: @category,status: :ok
      else
        record_errors(@category)
      end

    else
      record_not_found
    end
  end

  def destroy
    if  @category
      @category.destroy
      if @category.destroyed?
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

    def set_category
      @category = Category.category_by_id(params[:id])
    end

    def category_params
      params.permit(:category).permit(:name,:description)
    end


end
