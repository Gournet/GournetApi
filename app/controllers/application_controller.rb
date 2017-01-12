class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :add_headers_limit

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
  def add_headers_limit
    count = request.env['rack.attack.throttle_data']["req/ip"][:count]
    limit = request.env['rack.attack.throttle_data']["req/ip"][:limit]
    period = request.env['rack.attack.throttle_data']["req/ip"][:period]
    now = Time.now
    headers = {
      'X-RateLimit-Limit' => limit,
      'X-RateLimit-Remaining' => limit - count,
      'X-RateLimit-Reset' => (now + (period - now.to_i % period)).to_s
    }
    response.headers.merge!(headers)
  end
end
