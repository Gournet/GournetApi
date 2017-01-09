class Api::V1::AdminsController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:destroy]
  before_action :set_pagination, only: [:index,:admins_by_ids,:admins_by_not_ids,:admins_by_search]
  before_action :set_admin, only: [:show,:destroy]

  def index
    @admins = Admin.load_admins(@page,@per_page)
    if stale?(@admins)
      render json: @admins, status: :ok
    end
  end

  def show
    if @admin
      if stale?(@admin,public: true)
        render json: @admin, status: ok
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
    @admins =  Admin.admins_by_ids(params[:admin][:ids],@page,@per_page)
    render json: @admins, status: :ok
  end

  def admins_by_not_ids
    @admins =  Admin.admins_by_not_ids(params[:admin][:ids],@page,@per_page)
    render json: @admins, status: :ok
  end

  def admin_by_username
    @admin = Admin.admin_by_username(params[:admin][:username])
    if stale?(@admin,public: true)
      render json: @admin, status: :ok
    end
  end

  def admin_by_email
    @admin =  Admin.admin_by_email(params[:admin][:email])
    if stale?(@admin,public:true)
      render json: @admin, status: :ok
    end
  end

  def admins_by_search
    @admins =  Admin.search(params[:admin][:text],@page,@per_page)
    if stale?(@admins,public: true)
      render json: @admins,status: :ok
    end
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

    def set_admin
      @admin =  Admin.admin_by_id(params[:id])
    end


end
