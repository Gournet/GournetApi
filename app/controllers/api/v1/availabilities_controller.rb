class Api::V1::AvailabilitiesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_chef!, only: [:create,:update,:destroy]
  before_action :set_availability, only: [:update,:destroy]
  before_action :set_pagination, only: [:index,:today,:tomorrow,:next_seven_days,:tomorrow_with_count,:today_with_count,:availabilities_by_dish]

  def index
    @availabilities = nil
    if params.has_key?(:dish_id)
      @availabilities = Availability.availabilities_by_dish(params[:dish_id],@page,@per_page)
    else
      @availabilities = Availability.load_availabilities(@page,@per_page)
    end
    render json: @availabilities, status: :ok
  end

  def show
    if @availability
      if stale?(@availability,public: true)
        render json: @availability,status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @availability = Availability.new(availability_params)
    @availability.dish_id = params[:dish_id]
    if @availability.save()
      render json: @availability, status: :created
    else
      record_errors(@availabilty)
    end
  end

  def update
    if @availability
      chef = Dish.dish_by_id(params[:dish_id]).chef.id
      if chef == current_chef.id
        if @availability.update(availability_params)
          render json: @availability, status: :ok
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
    @availabilities = Availability.today.paginate(:page => @page,:per_page => @per_page)
    render json: @availabilities,status: :ok
  end

  def tomorrow
    @availabilities = Availability.tomorrow.paginate(:page => @page,:per_page => @per_page)
    render json: @availabilities, status: :ok
  end

  def next_seven_days
    @availabilites = Availability.next_seven_days(@page,@per_page)
    render json: @availabilites,status: :ok
  end

  def today_with_count
    @availabilities = Availability.today.available_count.paginate(:page => @page,:per_page => @per_page)
    render json: @availabilities,status: :ok
  end

  def tomorrow_with_count
    @availabilities = Availability.tomorrow.available_count.paginate(:page => @page,:per_page => @per_page)
    render json: @availabilities,status: :ok
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

end
