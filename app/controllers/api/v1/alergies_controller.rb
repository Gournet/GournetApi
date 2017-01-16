class Api::V1::AlergiesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :authenticate_user!, only: [:add_alergies,:remove_alergies]
  before_action :authenticate_chef!, only: [:add_alergies_dish,:remove_alergies_dish]
  before_action :set_alergy, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index,:alergies_by_ids, :alergies_by_not_ids,:alergies_with_users,:alergies_with_dishes,:alergies_with_dishes_and_users,:alergies_by_search]
  before_action :set_include

  def index
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.load_alergies(@page,@per_page) : Alergy.load_alergies(@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies,status: :ok, include: @include, root: "data",meta: meta_attributes(@alergies)
  end

  def show
    if @alergy
      if stale?(@alergy, public: true)
        render json: @alergy, status: :ok, include: @include, root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @alergy = Alergy.new(alergy_params)
    if @alergy.save
      render json: @alergy, status: :created, status_method: "Created", serializer: AttributesAlergySerializer, :location => api_v1_alergy_path(@alergy), root: "data"
    else
      record_errors(@alergy)
    end
  end

  def update
    if @alergy
      if @alergy.update(alergy_params)
        render json: @alergy, status: :ok, status_method: "Updated", serializer: AttributesAlergySerializer , root: "data"
      else
        record_errors(@alergy)
      end
    else
      record_not_found
    end
  end

  def destroy
    if @alergy
      @alergy.destroy
      if @alergy.destroyed?
        record_error
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def add_alergies
    @alergies = Alergy.where(id: params[:alergy][:ids])
    @user = User.user_by_id(current_user.id)
    @alergies.each do |a|
      @user.alergies << a
    end
    if @user.save
      record_success
    else
      record_error
    end
  end

  def add_alergies_dish
    @alergies = Alergy.where(id: params[:alergy][:ids])
    @chef = Chef.chef_by_id(current_chef.id)
    @dish = Dish.dish_by_id(params[:dish_id])
    if @dish
      if @dish.chef.id = @chef.id
        @alergies.each do |a|
          @dish.alergies << a
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

  def remove_alergies
    @alergiesByUser = AlergyByUser.where(user_id: current_user.id).where(alergy_id: params[:alergy][:ids])
    @alergiesByUser.each do |a|
      a.destroy
    end
    record_success
  end

  def remove_alergies_dish
    @dish = Dish.dish_by_id(params[:dish_id])
    if @dish
      if @dish.chef.id == current_chef.id
        @alergiesByDish = AlergyByDish.where(dish_id: @dish.id).where(alergy_id: params[:alergy][:ids])
        @alergiesByDish.each do |a|
          a.destroy
        end
        record_success
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def alergies_by_ids
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.alergies_by_ids(params[:alergy][:ids],@page,@per_page) : Alergy.alergies_by_ids(params[:alergy][:ids],@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies, status: :ok, include: @include, root: "data",meta: meta_attributes(@alergies)
  end

  def alergies_by_not_ids
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.alergies_by_not_ids(params[:alergy][:ids],@page,@per_page) : Alergy.alergies_by_not_ids(params[:alergy][:ids],@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies,status: :ok, include: @include, root: "data",meta: meta_attributes(@alergies)
  end

  def alergies_with_users
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.alergies_with_users(@page,@per_page) : Alergy.alergies_with_users(@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies, status: :ok, each_serializer: SimpleAlergySerializer, fields: set_fields, root: "data",meta: meta_attributes(@alergies)
  end

  def alergies_with_dishes
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.alergies_with_dishes(@page,@per_page) : Alergy.alergies_with_dishes(@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies, status: :ok, each_serializer: SimpleAlergySerializer, fields: set_fields,  root: "data",meta: meta_attributes(@alergies)
  end

  def alergies_with_dishes_and_users
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.alergies_with_dishes_and_users(@page,@per_page) : Alergy.alergies_with_dishes_and_users(@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies,status: :ok, each_serializer: SimpleAlergySerializer, fields: set_fields, root: "data",meta: meta_attributes(@alergies)
  end

  def alergies_by_search
    @alergies = params.has_key?(:sort) ? Alergy.unscoped.search_name(params[:alergy][:name],@page,@per_page) : Alergy.search_name(params[:alergy][:name],@page,@per_page)
    @alergies = set_orders(params,@alergies)
    render json: @alergies, status: :ok, include: @include, root: "data",meta: meta_attributes(@alergies)
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

    def set_alergy
      @alergy = Alergy.alergy_by_id(params[:id])
    end

    def alergy_params
      params.require(:alergy).permit(:name,:description)
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
          query = query.order_by_name(ord)
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
