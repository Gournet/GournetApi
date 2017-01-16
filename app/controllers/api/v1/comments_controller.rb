class Api::V1::CommentsController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update,:add_vote]
  devise_token_auth_group :member, contains: [:user, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action :set_comment, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index,:comments_by_dish,:comments_by_user,:comments_with_votes_by_dish]
  before_action :set_include

  def index
    @comments = nil
    if params.has_key?(:user_id)
      @comments = params.has_key?(:sort) ? Comment.unscoped.comments_by_user(params[:user_id],@page,@per_page) : Comment.comments_by_user(params[:user_id],@page,@per_page)
    elsif params.has_key?(:dish_id)
      @comments = params.has_key?(:sort) ? Comment.unscoped.comments_by_dish(params[:dish_id],@page,@per_page) : Comment.comments_by_dish(params[:dish_id],@page,@per_page)
    else
      @comments = params.has_key?(:sort) ?  Comment.unscoped.load_comments(@page,@per_page) : Comment.load_comments(@page,@per_page)
    end
    @comments = set_orders(params,@comments)
    render json: @comments,status: :ok, include: @include,root: "data",meta: meta_attributes(@comments)
  end

  def show
    if @comment
      if stale?(@comment, public:true)
        render json: @comments, status: :ok, include: @include,root: "data"
      end
    else
      record_not_found
    end
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user_id =  current_user.id
    @comment.dish_id =  params[:dish_id]
    if @comment.save
      render json: @comment, status: :created, status_method: "Created", serializer: AttributesCommentSerializer, :location => api_v1_comment_path(@comment),root: "data"
    else
      record_errors(@comment)
    end
  end

  def update
    if @comment
      if @comment.user.id ==  current_user.id
        if @comment.update(comment_params)
          render json: @comment, status: :ok, status_method: "Updated", serializer: AttributesCommentSerializer, root: "data"
        else
          record_errors(@comment)
        end
      else
        operation_not_allowed
      end
    else
      record_not_found
    end
  end

  def destroy
    if @comment
      if @comment.user.id == current_member.id || current_member.is_a?(Admin)
        @comment.destroy
        if @comment.destroyed?
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

  def comments_with_votes_by_dish
    @comments = params.has_key?(:sort) ? Comment.unscoped.comments_with_votes_by_dish(params[:dish_id],@page,@per_page) : Comment.comments_with_votes_by_dish(params[:dish_id],@page,@per_page)
    @comments = set_orders(params,@comments)
    render json: @comments,each_serializer: SimpleCommentSerializer, fields: set_fields, status: :ok,root: "data",meta: meta_attributes(@comments)
  end

  def add_vote
    if CommentVote.add_vote(current_user.id,params[:id],params[:comment][:vote])
      record_success
    else
      record_error
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

    def comment_params
      params.require(:comment).permit(:description)
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

    def set_comment
      @comment = Comment.comment_by_id(params[:id])
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
