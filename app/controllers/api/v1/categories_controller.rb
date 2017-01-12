class Api::V1::CategoriesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :set_category, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index,:categories_by_ids,:categories_by_not_ids,:categories_with_dishes,:categories_by_search]

  def index
    @categories = Category.load_categories(@page,@per_page)
    render json: @categories, status: :ok
  end

  def show
    if @category
      if stale?(@category,public: true)
        render json: @category, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category,status: :created
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

  def categories_by_ids
    @categories = Category.categories_by_ids(params[:category][:ids],@page,@per_page)
    render json: @categories, status: :ok
  end

  def categories_by_not_ids
    @categories = Category.categories_by_not_ids(params[:category][:ids],@page,@per_page)
    render json: @categories,status: :ok
  end

  def categories_with_dishes
    @categories = Category.categories_with_dishes(@page,@per_page)
    render json: @categories, status: :ok
  end

  def categories_by_search
    @categories = Category.search_name(params[:category][:name],@page,@per_page)
    render json: @categories,status: :ok
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

    def set_category
      @category = Category.category_by_id(params[:id])
    end

    def category_params
      params.require(:category).permit(:name,:description)
    end

end
