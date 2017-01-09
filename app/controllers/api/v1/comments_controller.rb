class Api::V1::CommentsController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update,:destroy,:add_vote]
  before_action :set_comment, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index,:comments_by_dish,:comments_by_user,:comments_with_votes_by_dish]

  def index
    @comments = nil
    if params.has_key?(:user_id)
      @comments = Comment.comments_by_user(params[:user_id],@page,@per_page)
    elsif params.has_key?(:dish_id)
      @comments = Comment.comments_by_dish(params[:dish_id],@page,@per_page)
    else
      @comments = Comment.load_comments(@page,@per_page)
    end

    if stale?(@comments,public: true)
      render json: @comments,status: :ok
    end
  end

  def show
    if @comment
      if stale?(@comment, public:true)
        render json: @comments, status: :ok
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
      render json: @comment, status: :ok
    else
      record_errors(@comment)
    end
  end

  def update
    if @comment
      if @comment.user.id ==  current_user.id
        if @comment.update(comment_params)
          render json: @comment, status: :ok
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
      if @comment.user.id == current_user.id
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

  def comments_by_dish
    @comments = Comment.comments_by_dish(params[:dish_id],@page,@per_page)
    if stale?(@comments,public: true)
      render json: @comments, status: :ok
    end
  end

  def comments_by_user
    @comments = Comment.comments_by_user(params[:user_id],@page,@per_page)
    if stale?(@comments,public: true)
      render json: @comments, status: :ok
    end
  end

  def comments_with_votes_by_dish
    @comments = Comment.comments_with_votes_by_dish(params[:dish_id],@page,@per_page)
    if stale?(@comments,public: true)
      render json: @comments, status: true
    end
  end

  def add_vote
    comment_params_vote
    CommentVote.add_vote(current_user.id,params[:id],params[:comment][:vote])
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
    def comment_params_vote
      params.require(:comment).permit(:vote)
    end

    def set_comment
      if params.has_key?(:dish_id)
        @comment =  Comment.comment_by_id_by_dish(params[:dish_id],params[:id])
      elsif params.has_key?(:user_id)
        @comment =  Comment.comment_by_id_by_user(params[:user_id],params[:id])
      else
        @comment = Comment.comment_by_id(params[:id])
      end
    end

end
