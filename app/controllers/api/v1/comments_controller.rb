class Api::V1::CommentsController < ApplicationController
  include ControllerUtility
  before_action :authenticate_user!, only: [:create,:update,:destroy]
  before_action :set_comment, only: [:show,:update,:destroy]
  before_action :set_pagination, only: [:index]

  def index
    if params.has_key?(:user_id)
      render json: Comment.comments_from_user(params[:user_id],@page,@per_page),status: :ok
    else
      render json: Comment.comments_from_dish(params[:dish_id],@page,@per_page),status: :ok
    end
  end

  def show
    if @comments
      render json: @comments, status: :ok
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

  private
    def set_pagination
      @page = params[:page][:number]
      @per_page = params[:page][:size]
      @page ||= 1
      @per_page ||= 10
    end

    def comment_params
      params.permit(:comment).require(:description,:is_possitive)
    end

    def set_comment
      if params.has_key?(:dish_id)
        @comment =  Comment.comment_by_id_and_dish(params[:dish_id],params[:id])
      else
        @comment =  Comment.comment_by_id_and_user(params[:user_id],params[:id])
      end
    end

end
