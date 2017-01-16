class Api::V1::AvailabilitiesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update,:destroy]
  before_action :set_availability, only: [:update,:destroy]
  before_action :set_pagination, only: [:index,:today,:tomorrow,:next_seven_days,:tomorrow_with_count,:today_with_count,:availabilities_by_dish]
  before_action :set_include

  def index
    @availabilities = nil
    if params.has_key?(:dish_id)
      @availabilities = params.has_key?(:sort) ? Availability.unscoped.availabilities_by_dish(params[:dish_id],@page,@per_page) : Availability.availabilities_by_dish(params[:dish_id],@page,@per_page)
    else
      @availabilities = params.has_key?(:sort) ? Availability.unscoped.load_availabilities(@page,@per_page) : Availability.load_availabilities(@page,@per_page)
    end
    @availabilities = set_orders(params,@availabilities)
    render json: @availabilities, status: :ok, include: @include, root: "data",meta: meta_attributes(@availabilities)
  end

  def show
    if @availability
      if stale?(@availability,public: true)
        render json: @availability,status: :ok, include: @include, root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @availability = Availability.new(availability_params)
    @availability.dish_id = params[:dish_id]
    if @availability.save()
      render json: @availability, status: :created, serializer: AttributesAvailabilitySerializer, status_method: "Created",  :location => api_v1_availability_path(@availability), root: "data"
    else
      record_errors(@availabilty)
    end
  end

  def update
    if @availability
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef == current_chef.id
        if @availability.update(availability_params)
          render json: @availability, status: :ok, serializer: AttributesAvailabilitySerializer, status_method: "Updated", root: "data"
        else
          record_errors(@availability)
        end
      else
        operation_not_allowed
      end
    else
      record_not_found
    end

  end

  def destroy
    if @availability
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef == current_chef.id
        @availability.destroy
        if @availability.destroyed?
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

  def today
    @availabilities = params.has_key?(:sort) ? Availability.unscoped.today.paginate(:page => @page,:per_page => @per_page) : Availability.today.paginate(:page => @page,:per_page => @per_page)
    @availabilities = set_orders(params,@availabilities)
    render json: @availabilities,status: :ok, include: @include, root: "data",meta: meta_attributes(@availabilities)
  end

  def tomorrow
    @availabilities = params.has_key?(:sort) ? Availability.unscoped.tomorrow.paginate(:page => @page,:per_page => @per_page) : Availability.tomorrow.paginate(:page => @page,:per_page => @per_page)
    @availabilities = set_orders(params,@availabilities)
    render json: @availabilities, status: :ok, include: @include, root: "data",meta: meta_attributes(@availabilities)
  end

  def next_seven_days
    @availabilites = params.has_key?(:sort) ? Availability.unscoped.next_seven_days(@page,@per_page) : Availability.next_seven_days(@page,@per_page)
    @availabilities = set_orders(params,@availabilities)
    render json: @availabilites,status: :ok, include: @include, root: "data",meta: meta_attributes(@availabilities)
  end

  def today_with_count
    @availabilities = params.has_key?(:sort) ? Availability.unscoped.today.available_count.paginate(:page => @page,:per_page => @per_page) : Availability.today.available_count.paginate(:page => @page,:per_page => @per_page)
    @availabilities = set_orders(params,@availabilities)
    render json: @availabilities,status: :ok, include: @include, root: "data",meta: meta_attributes(@availabilities)
  end

  def tomorrow_with_count
    @availabilities = params.has_key?(:sort) ? Availability.unscoped.tomorrow.available_count.paginate(:page => @page,:per_page => @per_page) : Availability.tomorrow.available_count.paginate(:page => @page,:per_page => @per_page)
    @availabilities = set_orders(params,@availabilities)
    render json: @availabilities,status: :ok, include: @include, root: "data",meta: meta_attributes(@availabilities)
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

    def set_availability
      @availability = Availability.availability_by_id(params[:id])
    end

    def availability_params
      params.require(:availability).permit(:day,:count,:available,:end_time,:repeat)
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
        when "day", "-day"
          query = query.order_by_day(ord)
        when "count", "-count"
          query = query.order_by_count(ord)
        when "end_time", "-end_time"
          query = query.order_by_end_time(ord)
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
