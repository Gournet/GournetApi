class Api::V1::FacebookController < ApplicationController
  after_action :update_response ,only: [:create_facebook_account]
  @new_auth_header = nil
  def create_facebook_account
    user_params
    @user = User.where({
      uid: params[:uid],
      provider: "facebook"
    }).first_or_initialize
    if @user.new_record?
      @user.set_password
    end
    @user.set_attributes(params)
    if @user.save
      @new_auth_header = @user.set_token
      render_success_login(@user)
    else
      render_error_login(@user)
    end
  end

  private
  def update_response
    response.headers.merge!(@new_auth_header) if @new_auth_header
  end
  def is_json_api
    return false unless defined?(ActiveModel::Serializer)
    return ActiveModel::Serializer.setup do |config|
      config.adapter == :json_api
    end if ActiveModel::Serializer.respond_to?(:setup)
    return ActiveModelSerializers.config.adapter == :json_api
  end
  def resource_data(user,opts={})
    response_data = opts[:resource_json] || user.as_json
    if is_json_api
      response_data['type'] = @resource.class.name.parameterize
    end
    response_data
  end

  def resource_errors(user)
    return user.errors.to_hash.merge(full_messages: user.errors.full_messages)
  end
  def render_success_login(user)
    render json: {
      status: 'success',
      data: resource_data(user)
    },status: 200
  end
  def render_error_login(user)
    render json: {
      status: 'error',
      data: resource_data(user),
      error: resource_errors(user)
    }, status: 422
  end
  def user_params
    params.permit(:name,:lastname,:username,:birthday,:mobile,:avatar,:uid)
  end
end
