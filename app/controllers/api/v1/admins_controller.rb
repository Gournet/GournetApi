class Api::V1::AdminsController < ApplicationController
  before_action :authenticate_admin!, only: [:index]
  before_action :set_pagination, only: [:index]
  before_action :set_admin, only: [:show]

  def index
    render json: Admin.load_admins(@page,@per_page), status: :ok
  end

  def show
    if @admin
      if stale?(last_modified: @admin.updated_at)
        render json: @admin, status: ok
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
    def set_admin
      @admin =  Admin.admin_by_id(params[:id])
    end

end
