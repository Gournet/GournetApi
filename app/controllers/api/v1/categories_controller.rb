class Api::V1::CategoriesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :authenticate_chef!, only: [:add_categories_dish,:remove_categories_dish]
  before_action :set_category, only: [:show,:update,:destroy]
  before_action only: [:index,:categories_by_ids,:categories_by_not_ids,:categories_with_dishes,:categories_by_search] do
    set_pagination(params)
  end
  before_action do
    set_include(params)
  end

  def index
    @categories = nil
    if params.has_key?(:dish_id)
      @categories = params.has_key?(:sort) ? Category.unscoped.categories_by_dish(params[:dish_id],@page,@per_page) : Category.categories_by_dish(params[:dish_id],@page,@per_page)
    else
      @categories = params.has_key?(:sort) ? Category.unscoped.load_categories(@page,@per_page) : Category.load_categories(@page,@per_page)
    end
    @categories = set_orders(params,@categories)
    if params.has_key?(:dish_id)
      render json: @categories, status: :ok, fields: set_fields, each_serailizer: SimpleCategorySerializer, root: "data",meta: meta_attributes(@categories)
    else
      render json: @categories, status: :ok, include: @include, root: "data",meta: meta_attributes(@categories)
    end
  end

  def show
    if @category
      if stale?(@category,public: true)
        render json: @category, status: :ok, include: @include, root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category,status: :created, serializer: AttributesCategorySerializer, status_method: "Created", :location => api_v1_category_path(@category), root: "data"
    else
      record_errors(@category)
    end
  end

  def update
    if @category
      if @category.update(category_params)
        render json: @category,serializer: AttributesCategorySerializer, status_method: "Updated", status: :ok, root: "data"
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

  def add_categories_dish
    @categories = Category.where(id: params[:category][:ids])
    @chef = Chef.chef_by_id(current_chef.id)
    @dish = Dish.dish_by_id(params[:dish_id])
    if @dish
      if  @dish.chef.id == @chef.id
        @categories.each do |c|
          @dish.categories  << c
        end
        if @dish.save
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

  def remove_categories_dish
    @dish = Dish.dish_by_id(params[:dish_id])
    if @dish
      if @dish.chef.id == current_chef.id
        @categoriesByDish = CategoryByDish.where(dish_id: @dish.id).where(category_id: params[:category][:ids])
        @categoriesByDish.each do |c|
          c.destroy
        end
        record_success
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def categories_by_ids
    @categories = params.has_key?(:sort) ? Category.unscoped.categories_by_ids(params[:category][:ids],@page,@per_page) : Category.categories_by_ids(params[:category][:ids],@page,@per_page)
    @categories = set_orders(params,@categories)
    render json: @categories, status: :ok, include: @include, root: "data",meta: meta_attributes(@categories)
  end

  def categories_by_not_ids
    @categories = params.has_key?(:sort) ? Category.unscoped.categories_by_not_ids(params[:category][:ids],@page,@per_page) : Category.categories_by_not_ids(params[:category][:ids],@page,@per_page)
    @categories = set_orders(params,@categories)
    render json: @categories,status: :ok, include: @include, root: "data",meta: meta_attributes(@categories)
  end

  def categories_with_dishes
    @categories = params.has_key?(:sort) ? Category.unscoped.categories_with_dishes(@page,@per_page) : Category.categories_with_dishes(@page,@per_page)
    @categories = set_orders(params,@categories)
    render json: @categories, status: :ok, root: "data",meta: meta_attributes(@categories)
  end

  def categories_by_search
    @categories = params.has_key?(:sort) ? Category.unscoped.search_name(params[:category][:name],@page,@per_page) : Category.search_name(params[:category][:name],@page,@per_page)
    @categories = set_orders(params,@categories)
    render json: @categories,status: :ok, include: @include, each_serailizer: SimpleCategorySerializer, fields: set_fields(params), root: "data",meta: meta_attributes(@categories)
  end

  private

    def set_category
      @category = Category.category_by_id(params[:id])
    end

    def category_params
      params.require(:category).permit(:name,:description)
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "name", "-name"
          query = query.order_by_day(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
    end

end
