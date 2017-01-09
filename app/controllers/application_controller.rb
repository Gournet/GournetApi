class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    if resource_class == User
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username,:name,:lastname,:avatar,:mobile,:birthday])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name,:lastname,:avatar,:mobile,:current_password])
    elsif resource_class == Admin
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username,:name,:lastname,:avatar,:mobile])
      devise_parameter_sanitizer.permit(:account_update,keys: [:name,:lastname,:avatar,:mobile,:current_password])
    else
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username,:name,:lastname,:avatar,:mobile,:type_chef,:description,:speciality,:expertise,:food_types,:birthday])
      devise_parameter_sanitizer.permit(:account_update,keys: [:name,:lastname,:avatar,:mobile,:description,:speciality,:expertise,:type,:food_types,:current_password])
    end

  end
end
