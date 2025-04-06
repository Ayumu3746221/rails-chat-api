class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private
  
  def authenticate_user!
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, Rails.application.credentials.devise_jwt_secret_key!).first
      @current_user_id = jwt_payload['sub']
    else
      render json: { error: 'Authorization header is missing' }, status: :unauthorized
    end
  rescue JWT::DecodeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
  
  def current_user
    @current_user ||= User.find(@current_user_id)
  end
end
