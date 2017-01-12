class Api::V1::AlergiesController < ApplicationController
  include ControllerUtility
  before_action :authenticate_admin!, only: [:create,:update,:destroy]
  before_action :set_alergy, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index,:alergies_by_ids, :alergies_by_not_ids,:alergies_with_users,:alergies_with_dishes,:alergies_with_dishes_and_users,:alergies_by_search]

  def index
    @alergies = Alergy.load_alergies(@page,@per_page)
    render json: @alergies,status: :ok
  end

  def show
    if @alergy
      if stale?(@alergy, public: true)
        render @alergy, status: :ok
      end
    else
      record_not_found
    end
  end

  def create
    @alergy = Alergy.new(alergy_params)
    if @alergy.save
      render json: @alergy, status: :created
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

  def alergies_by_ids
    @alergies = Alergy.alergies_by_ids(params[:alergy][:ids],@page,@per_page)
    if stale?(@alergies,public: true)
      render json: @alergies, status: :ok
    end
  end

  def alergies_by_not_ids
    @alergies = Alergy.alergies_by_ids(params[:alergy][:ids],@page,@per_page)
    if stale?(@alergies,public: true)
      render json: @alergies,status: :ok
    end
  end

  def alergies_with_users
    @alergies = Alergy.alergies_with_users(@page,@per_page)
    render json: @alergies, status: :ok

  end

  def alergies_with_dishes
    @alergies = Alergy.alergies_with_dishes(@page,@per_page)
    render json: @alergies, status: :ok
  end

  def alergies_with_dishes_and_users
    @alergies = Alergy.alergies_with_dishes_and_users(@page,@per_page)
    render json: @alergies,status: :ok
  end

  def alergies_by_search
    @alergies = Alergy.search_name(params[:alergy][:name],@page,@per_page)
    render json: @alergies, status: :ok
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

    def set_alergy
      @alergy = Alergy.alergy_by_id(params[:id])
    end

    def alergy_params
      params.require(:alergy).permit(:name,:description)
    end

end
