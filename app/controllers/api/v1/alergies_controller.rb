class Api::V1::AlergiesController < ApplicationController
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :set_alergy, only: [:show,:create,:update]
  before_action :set_pagination, only: [:index]
  def index
    render json: Alergy.load_alergies(@page,@per_page),status: :ok
  end

  def show
    if @alergy
      if stale?(last_modified: @alergy.updated_at)
        render @alergy, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @alergy = Alergy.new(alergy_params)
    if @alergy.save
      render json: @alergy, status: :ok
    else
      record_errors(@alergy)
    end
  end

  def update
    if @alergy
      if @alergy.update(alergy_params)
        render json: @alergy, status: :ok
      else
        record_errors(@alergy)
      end
    else
      record_not_found
    end
  end

  def destroy
    if @alergy
      @alergy.destroy
      if @alergy.destroyed?
        record_success
      else
        record_error
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
    def set_alergy
      @alergy = Alergy.alergy_by_id(params[:id])
    end

    def alergy_params
      params.require(:alergy).permit(:name,:description)
    end
end
