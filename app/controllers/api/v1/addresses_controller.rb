class Api::V1::AddressesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update,:destroy]
  before_action :set_pagination, only: [:index]
  before_action :set_address, only: [:show,:update,:destroy]
  before_action :set_addresses, only: [:index]

  def index
    render json: @addresses, status: :ok
  end

  def show
    if @address
      if stale?(last_modified: @address.updated_at)
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
      if @address.user_id == current_user.id
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

    def set_addresses
      @addresses = Address.addresses_by_user(params[:user_id],@page,@per_page)
    end

    def address_params
      params.require(:address).permit(:address,:lat,:lng)
    end

end
