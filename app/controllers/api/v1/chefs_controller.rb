class Api::V1::ChefsController < ApplicationController
  include ControllerUtility
  before_action :set_pagination, only: [:index,:chefs_by_ids,:chefs_by_not_ids,:chefs_with_dishes,
    :chefs_with_followers,:chefs_with_orders,:chefs_with_orders_today,:chefs_with_orders_yesterday,
    :chefs_with_orders_week,:chefs_with_orders_month,:chefs_with_orders_year,:professional,:amateur,:catering_specialist,:cooking_student,:other]
  before_action :set_chef, only: [:show,:destroy,:follow,:unfollow]
  before_action :authenticate_admin!, only: [:destroy]
  before_action :authenticate_user!, only: [:follow,:unfollow]
  before_action :set_include

  def index
    @chefs = Chef.load_chefs(@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def show
    if @chef
      if stale?(@chef,public: true)
        render json: @chef,status: :ok, include: @include, root: "data"
      end
    else
      record_not_found
    end
  end

  def destroy
    if @chef
      @chef.destroy
      if @chef.destroyed?
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def professional
    @chefs = Chef.profesional.paginate(:page => @page, :per_page => @per_page)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def amateur
    @chefs = Chef.amateur.paginate(:page => @page, :per_page => @per_page)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def catering_specialist
    @chefs = Chef.especializado_en_catering.paginate(:page => @page, :per_page => @per_page)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def cooking_student
    @chefs = Chef.estudiante_de_cocina.paginate(:page => @page,:per_page => @per_page)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def other
    @chefs = Chef.otro.paginate(:page => @page, :per_page => @per_page)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def chefs_by_ids
    @chefs = Chef.chefs_by_ids(params[:chef][:ids],@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def chefs_by_not_ids
    @chefs = Chef.chefs_by_not_ids(params[:chef][:ids],@page,@per_page)
    render json: @chefs, status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def chefs_with_dishes
    @chefs = Chef.chefs_with_dishes(@page,@per_page)
    render json: @chefs,status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer,meta: meta_attributes(@chefs)
  end

  def chefs_with_followers
    @chefs = Chef.chefs_with_followers(@page, @per_page)
    render json: @chefs,status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer,meta: meta_attributes(@chefs)
  end

  def chefs_with_orders
    @chefs = Chef.chefs_with_orders(@page,@per_page)
    render json: @chefs, status: :ok, root: "data",fields: set_fields, each_serializer: SimpleChefSerializer, meta: meta_attributes(@chefs)
  end

  def chefs_with_orders_today
    @chefs = Chef.chefs_with_orders_today(@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_today
    @chef = Chef.orders_today(params[:id])
    render json: @chefs,status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_yesterday
    @chefs = Chef.chefs_with_orders_yesterday(@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_yesterday
    @chefs = Chef.orders_yesterday(params[:id])
    render json: @chefs, status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_week
    @chefs = Chef.chefs_with_orders_week(@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_week
    @chefs = Chef.orders_week(params[:id])
    render json: @chefs,status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_month
    @chefs = Chef.chefs_with_orders_month(params[:chef][:year].to_i,params[:chef][:month].to_i,@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_month
    @chefs = Chef.orders_month(params[:id],params[:chef][:year].to_i,params[:chef][:month].to_i)
    render json: @chefs, status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_year
    @chefs = Chef.chefs_with_orders_year(params[:chef][:year].to_i,@page,@per_page)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_year
    @chefs = Chef.orders_year(params[:id],params[:chef][:year].to_i)
    render json: @chefs, status: :ok, include: @include, root: "data"
  end

  def best_seller_chefs_per_month
    @chefs = Chef.best_seller_chefs_per_month(params[:chef][:year].to_i,params[:chef][:month].to_i)
    render json: @chefs, status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def best_seller_chefs_per_year
    @chefs = Chef.best_seller_chefs_per_year(params[:chef][:year].to_i)
    render json: @chefs, status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def follow
    if @chef
      if Follower.follow(current_user.id,@chef.id)
        record_success
      else
        record_error
      end
    else
      record_not_found
    end
  end

  def unfollow
    if @chef
      follower = Follower.unfollow(current_user.id,@chef.id)
      if follower
        if follower.destroyed?
          record_success
        else
          record_error
        end
      else
        record_not_found
      end
    else
      record_not_found
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

    def set_fields
      array = params[:fields].split(",") if params.has_key?(:fields)
      array ||= []
      array_s = nil
      if !array.empty?
        array_s = []
      end
      array.each do |a|
        array_s.push(a.to_sym)
      end
      array_s
    end

    def set_chef
      @chef = Chef.chef_by_id(params[:id])
    end

    def set_include
      temp = params[:include]
      temp ||= "*"
      if temp.include? "**"
        temp = "*"
      end
      @include = temp
    end


end
