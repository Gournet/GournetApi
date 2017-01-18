class Api::V1::CommentsController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update,:add_vote]
  devise_token_auth_group :member, contains: [:user, :admin]
  before_action :authenticate_member!, only: [:destroy]
  before_action :set_comment, only: [:show,:update,:destroy]
  before_action only: [:index,:comments_by_dish,:comments_by_user,:comments_with_votes_by_dish] do
    set_pagination(params)
  end
  before_action do
    set_include(params)
  end

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
    dish = Dish.dish_by_id(params[:dish_id])
    if dish
      @order = Order.where(dish_id: dish.id).where(user_id: current_user.id).first
      if @order || @order.day > Date.today
        @comment.dish_id =  dish.id
        if @comment.save
          render json: @comment, status: :created, status_method: "Created", serializer: AttributesCommentSerializer, :location => api_v1_comment_path(@comment),root: "data"
        else
          record_errors(@comment)
        end
      else
        record_add_comment
      end
    else
      record_not_found
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
    render json: @comments,each_serializer: SimpleCommentSerializer, fields: set_fields(params), status: :ok,root: "data",meta: meta_attributes(@comments)
  end

  def add_vote
    if CommentVote.add_vote(current_user.id,params[:id],params[:comment][:vote])
      record_success
    else
      record_error
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:description)
    end

    def set_comment
      @comment = Comment.comment_by_id(params[:id])
    end

    def set_order(val,query)
      ord = val[0] == '-' ? "DESC" : "ASC"
      case val.downcase
        when "date", "-date"
          query = query.order_by_created_at(ord)
      end
      query
    end

end
