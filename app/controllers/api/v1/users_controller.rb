class Api::V1::UsersController < ApplicationController
  before_action :set_pagination, only: [:index]
  before_action :set_user, only: [:show]

  def index
    render json: User.load_users(@page,@per_page), status: :ok
  end

  def show
    if @user
      if stale?(last_modified: @user.updated_at,public: true)
        render json: @user, status: :ok
      end
    else
      render json: { data: {
        status: "Error",
        error: "We can't find a valid record"
      }
    }, status: :not_found
    end
  end

  private
    def set_pagination
      @page = params[:page][:number]
      @per_page = params[:page][:size]
      @page ||= 1
      @per_page ||= 10
    end
    def set_user
      @user = User.user_by_id(params[:id])
    end
end
