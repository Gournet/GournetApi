class Api::V1::AddressesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update]
  devise_token_auth_group :member, contains: [:user, :admin]
  before_action :authenticate_member, only: [:destroy]
  before_action :set_pagination, only: [:index,:popular_addresses,:find_adddress_by_lat_and_lng,:addresses_with_orders]
  before_action :set_address, only: [:show,:update,:destroy]

  def index
    @addresses = Address.addresses_by_user(params[:user_id],@page,@per_page)
    if stale?(@addresses,public: true)
      render json: @addresses, status: :ok
    end
  end

  def show
    if @address
      if stale?(@address,public: true)
        render json: @address, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @addres = Address.new(address_params)
    @address.user_id = params[:user_id]
    if @address.save
      render json: @address, status: :created
    else
      record_errors(@address)
    end
  end

  def update
    if @address
      if @address.user_id == current_user.id
        if @address.update(address_params)
          render json: @address, status: :ok
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
    @addresses = Address.popular_addresses_by_orders_and_user(params[:address][:user_id],@page,@per_page)
    if stale?(@addresses,public: true)
      render json: @addresses, status: :ok
    end
  end

  def find_adddress_by_lat_and_lng
    @addresses = Address.address_by_lat_and_lng(params[:address][:lat],params[:address][:lng],@page,@per_page)
    if statle?(@addresses,public: true)
      render json: @addresses, status: :ok
    end
  end

  def addresses_with_orders
    @addresses =  Address.addresses_with_orders(@page,@per_page)
    if statle?(@addresses,public: true)
      render json: @addresses, status: :ok
    end
  end

  private
    def set_pagination
      @page = params[:page][:number]
      @per_page = params[:page][:size]
      @page ||= 1
      @per_page ||= 10
    end
    def set_address
      @address = Address.address_by_id_and_user(params[:id],params[:user_id])
    end

    def address_params
      params.require(:address).permit(:address,:lat,:lng)
    end

end
