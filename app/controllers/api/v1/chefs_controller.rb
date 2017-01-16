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
    @chefs = params.has_key?(:sort)? Chef.unscoped.load_chefs(@page,@per_page) : Chef.load_chefs(@page,@per_page)
    @chefs = set_orders(params,@chefs)
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
    @chefs = params.has_key?(:sort) ? Chef.unscoped.profesional.paginate(:page => @page, :per_page => @per_page) : Chef.profesional.paginate(:page => @page, :per_page => @per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def amateur
    @chefs = params.has_key?(:sort) ? Chef.unscoped.amateur.paginate(:page => @page, :per_page => @per_page)  : Chef.amateur.paginate(:page => @page, :per_page => @per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def catering_specialist
    @chefs = params.has_key?(:sort) ? Chef.unscoped.especializado_en_catering.paginate(:page => @page, :per_page => @per_page) : Chef.especializado_en_catering.paginate(:page => @page, :per_page => @per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def cooking_student
    @chefs = params.has_key?(:sort) ? Chef.unscoped.estudiante_de_cocina.paginate(:page => @page,:per_page => @per_page) : Chef.estudiante_de_cocina.paginate(:page => @page,:per_page => @per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def other
    @chefs = params.has_key?(:sort) ? Chef.unscoped.otro.paginate(:page => @page, :per_page => @per_page) : Chef.otro.paginate(:page => @page, :per_page => @per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data",meta: meta_attributes(@chefs), fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def chefs_by_ids
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_by_ids(params[:chef][:ids],@page,@per_page) : Chef.chefs_by_ids(params[:chef][:ids],@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def chefs_by_not_ids
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_by_not_ids(params[:chef][:ids],@page,@per_page) : Chef.chefs_by_not_ids(params[:chef][:ids],@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def chefs_with_dishes
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_dishes(@page,@per_page) : Chef.chefs_with_dishes(@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer,meta: meta_attributes(@chefs)
  end

  def chefs_with_followers
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_followers(@page, @per_page) : Chef.chefs_with_followers(@page, @per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer,meta: meta_attributes(@chefs)
  end

  def chefs_with_orders
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_orders(@page,@per_page) : Chef.chefs_with_orders(@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data",fields: set_fields, each_serializer: SimpleChefSerializer, meta: meta_attributes(@chefs)
  end

  def chefs_with_orders_today
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_orders_today(@page,@per_page) : Chef.chefs_with_orders_today(@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_today
    @chef = Chef.orders_today(params[:id])
    render json: @chefs,status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_yesterday
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_orders_yesterday(@page,@per_page) : Chef.chefs_with_orders_yesterday(@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_yesterday
    @chef = Chef.orders_yesterday(params[:id])
    render json: @chef, status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_week
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_orders_week(@page,@per_page) : Chef.chefs_with_orders_week(@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_week
    @chef = Chef.orders_week(params[:id])
    render json: @chef,status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_month
    @chefs = params.has_key?(:sort) ? Chef.unscoped.chefs_with_orders_month(params[:chef][:year].to_i,params[:chef][:month].to_i,@page,@per_page) : Chef.chefs_with_orders_month(params[:chef][:year].to_i,params[:chef][:month].to_i,@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chefs,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_month
    @chefs = Chef.orders_month(params[:id],params[:chef][:year].to_i,params[:chef][:month].to_i)
    render json: @chefs, status: :ok, include: @include, root: "data"
  end

  def chefs_with_orders_year
    @chef = params.has_key?(:sort) ? Chef.unscoped.chefs_with_orders_year(params[:chef][:year].to_i,@page,@per_page) : Chef.chefs_with_orders_year(params[:chef][:year].to_i,@page,@per_page)
    @chefs = set_orders(params,@chefs)
    render json: @chef,status: :ok, include: @include, root: "data",meta: meta_attributes(@chefs)
  end

  def orders_year
    @chef = Chef.orders_year(params[:id],params[:chef][:year].to_i)
    render json: @chef, status: :ok, include: @include, root: "data"
  end

  def best_seller_chefs_per_month
    @chefs = params.has_key?(:sort) ? Chef.unscoped.best_seller_chefs_per_month(params[:chef][:year].to_i,params[:chef][:month].to_i) : Chef.best_seller_chefs_per_month(params[:chef][:year].to_i,params[:chef][:month].to_i)
    @chefs = set_orders(params,@chefs)
    render json: @chefs, status: :ok, root: "data", fields: set_fields, each_serializer: SimpleChefSerializer
  end

  def best_seller_chefs_per_year
    @chefs = params.has_key?(:sort) ? Chef.unscoped.best_seller_chefs_per_year(params[:chef][:year].to_i) : Chef.best_seller_chefs_per_year(params[:chef][:year].to_i)
    @chefs = set_orders(params,@chefs)
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

    def set_orders(params,query)
      if params.has_key?(:sort)
        values = params[:sort].split(",")
        values.each  do |val|
          query = set_order(val,query)
        end
      end
      query
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "name", "-name"
          query = query.order_by_day(ord)
        when "email", "-email"
          query = query.order_by_email(ord)
        when "username", "-username"
          query = query.order_by_username(ord)
        when "lastname", "-lastname"
          query = query.order_by_lastname(ord)
        when "birthday", "-birthday"
          query = query.order_by_birthday(ord)
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
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
