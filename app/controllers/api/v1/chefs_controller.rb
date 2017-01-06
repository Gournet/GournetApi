class Api::V1::ChefsController < ApplicationController
  before_action :set_pagination, only: [:index]
  before_action :set_chef, only: [:show]

  def index
    render json: Chef.load_chefs(@page,@per_page),status: :ok
  end

  def show
    if @chef
      if stale?(last_modified: @chef.updated_at)
        render json: @chef,status: :ok
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
    def set_chef
      @chef = Chef.chef_by_id(params[:id])
    end
end
