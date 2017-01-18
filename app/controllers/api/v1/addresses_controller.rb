class Api::V1::AddressesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update]
  devise_token_auth_group :member, contains: [:user, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action only: [:index,:popular_addresses,:find_adddress_by_lat_and_lng,:addresses_with_orders] do
    set_pagination(params)
  end
  before_action :set_address, only: [:show,:update,:destroy]
  before_action  do
    set_include(params)
  end

  def index
    if params.has_key?(:user_id)
      @addresses = params.has_key?(:sort) ? Address.unscoped.addresses_by_user(params[:user_id],@page,@per_page) : Address.addresses_by_user(params[:user_id],@page,@per_page)
    else
      @addresses = params.has_key?(:sort) ? Address.unscoped.load_addresses(@page,@per_page) : Address.load_addresses(@page,@per_page)
    end
    @addresses = set_orders(params,@addresses)
    render json: @addresses, status: :ok, include: @include, root: "data", meta: meta_attributes(@addresses)
  end

  def show
    if @address
      if stale?(@address,public: true)
        render json: @address, status: :ok, include: @include, root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @address = Address.new(address_params)
    @address.user_id = current_user.id
    if @address.save
      render json: @address, status: :created, status_method: "Created", serializer: AttributesAddressSerializer,  :location => api_v1_address_path(@address), root: "data"
    else
      record_errors(@address)
    end
  end

  def update
    if @address
      if @address.user_id == current_user.id
        if @address.update(address_params)
          render json: @address, status: :ok, status_method: "Updated",  serializer: AttributesAddressSerializer, root: "data"
        else
          record_errors(@address)
        end
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def destroy
    if @address
      if @address.user.id == current_member.id || current_member.is_a?(Admin)
        @address.destroy
        if @address.destroyed?
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

  def popular_addresses
    @addresses = params.has_key?(:sort) ? Address.unscoped.popular_addresses_by_orders_and_user(params[:user_id],@page,@per_page) : Address.popular_addresses_by_orders_and_user(params[:user_id],@page,@per_page)
    @addresses = set_orders(params,@addresses)
    render json: @addresses, status: :ok, each_serializer: SimpleAddressSerializer, fields: set_fields(params), root: "data",meta: meta_attributes(@addresses)
  end

  def find_adddress_by_lat_and_lng
    @addresses = params.has_key?(:sort) ? Address.unscoped.address_by_lat_and_lng(params[:address][:lat].to_f,params[:address][:lng].to_f,@page,@per_page) : Address.address_by_lat_and_lng(params[:address][:lat].to_f,params[:address][:lng].to_f,@page,@per_page)
    @addresses = set_orders(params,@addresses)
    render json: @addresses, status: :ok, include: @include, root: "data",meta: meta_attributes(@addresses)
  end

  def addresses_with_orders
    @addresses =  params.has_key?(:sort) ? Address.unscoped.addresses_with_orders(@page,@per_page) : Address.addresses_with_orders(@page,@per_page)
    @addresses = set_orders(params,@addresses)
    render json: @addresses, status: :ok, each_serializer: SimpleAddressSerializer, fields: set_fields(params), root: "data",meta: meta_attributes(@addresses)
  end

  private

    def set_address
      @address = Address.address_by_id(params[:id])
    end

    def address_params
      params.require(:address).permit(:address,:lat,:lng)
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "address", "-address"
          query = query.order_by_address(ord)
        when "lat", "-lat"
          query = query.order_by_lat(ord)
        when "lng", "-lng"
          query = query.order_by_lng(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
    end
end
