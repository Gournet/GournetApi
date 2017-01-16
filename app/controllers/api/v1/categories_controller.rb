class Api::V1::CategoriesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :authenticate_chef!, only: [:add_categories_dish,:remove_categories_dish]
  before_action :set_category, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index,:categories_by_ids,:categories_by_not_ids,:categories_with_dishes,:categories_by_search]
  before_action :set_include

  def index
    @categories = params.has_key?(:sort) ? Category.unscoped.load_categories(@page,@per_page) : Category.load_categories(@page,@per_page)
    @categories = set_orders(params,@categories)
    render json: @categories, status: :ok, include: @include, root: "data",meta: meta_attributes(@categories)
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
    render json: @categories,status: :ok, include: @include, each_serailizer: SimpleCategorySerializer, fields: set_fields, root: "data",meta: meta_attributes(@categories)
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

    def set_fields
      array = params[:fields].split(",") if params.has_key?(:fields)
      array ||= []
      array_s = nil
      if !array.empty?
        array_s = []
      end
      array.each do |a|
        array_s.push(a.to_sym)
      end
      array_s
    end

    def set_category
      @category = Category.category_by_id(params[:id])
    end

    def category_params
      params.require(:category).permit(:name,:description)
    end

    def set_orders(params,query)
      if params.has_key?(:sort)
        values = params[:sort].split(",")
        values.each  do |val|
          query = set_order(val,query)
        end
      end
      query
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

    def set_include
      temp = params[:include]
      temp ||= "*"
      if temp.include? "**"
        temp = "*"
      end
      @include = temp
    end


end
