class Api::V1::AdminsController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:destroy]
  before_action only: [:index,:admins_by_ids,:admins_by_not_ids,:admins_by_search] do
    set_pagination(params)
  end
  before_action :set_admin, only: [:show,:destroy]

  def index
    @admins = params.has_key?(:sort) ? Admin.unscoped.load_admins(@page,@per_page) : Admin.load_admins(@page,@per_page)
    @admins = set_orders(params,@admins)
    render json: @admins, status: :ok, root: "data", fields: set_fields(params), meta: meta_attributes(@admins)
  end

  def show
    if @admin
      if stale?(@admin,public: true)
        render json: @admin, fields: set_fields(params), status: :ok, root: "data"
      end
    else
      record_not_found
    end
  end

  def destroy
    if @admin
      if @admin.id !=  current_admin.id
        @admin.destroy
        if @user.destroyed?
          record_success
        else
          record_error
        end
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def admins_by_ids
    @admins =  params.has_key?(:sort) ? Admin.unscoped.admins_by_ids(params[:admin][:ids],@page,@per_page) : Admin.admins_by_ids(params[:admin][:ids],@page,@per_page)
    @admins = set_orders(params,@admins)
    render json: @admins, status: :ok, fields: set_fields(params), root: "data",meta: meta_attributes(@admins)
  end

  def admins_by_not_ids
    @admins =  params.has_key?(:sort) ? Admin.unscoped.admins_by_not_ids(params[:admin][:ids],@page,@per_page) : Admin.admins_by_not_ids(params[:admin][:ids],@page,@per_page)
    @admins = set_orders(params,@admins)
    render json: @admins, status: :ok, fields: set_fields(params), root: "data",meta: meta_attributes(@admins)
  end

  def admin_by_username
    @admin = Admin.admin_by_username(params[:admin][:username])
    if stale?(@admin,public: true)
      render json: @admin, fields: set_fields(params), status: :ok, root: "data"
    end
  end

  def admin_by_email
    @admin =  Admin.admin_by_email(params[:admin][:email])
    if stale?(@admin,public:true)
      render json: @admin, fields: set_fields(params),status: :ok, root: "data"
    end
  end

  def admins_by_search
    @admins =  params.has_key?(:sort) ? Admin.unscoped.search(params[:admin][:text],@page,@per_page) : Admin.search(params[:admin][:text],@page,@per_page)
    @admins = set_orders(params,@admins)
    render json: @admins,fields: set_fields(params),status: :ok, root: "data",meta: meta_attributes(@admins)
  end

  private
  
    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "username", "-username"
          query = query.order_by_username(ord)
        when "email", "-email"
          query = query.order_by_email(ord)
        when "name", "-name"
          query = query.order_by_name(ord)
        when "lastname", "-lastname"
          query = query.order_by_lastname(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
    end

    def set_admin
      @admin =  Admin.admin_by_id(params[:id])
    end


end
