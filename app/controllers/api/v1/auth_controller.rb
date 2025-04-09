class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:signup, :login]

  def signup
    user = User.new(user_params)
    
    if user.save
      access_token = generate_access_token(user)
      refresh_token = generate_refresh_token(user)

      render json: {
        user: {
          id: user.id,
          email: user.email,
          role: user.role
        },
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      access_token = generate_access_token(user)
      refresh_token = generate_refresh_token(user)

      render json: {
        user: {
          id: user.id,
          email: user.email,
          role: user.role
        },
        access_token: access_token,
        refresh_token: refresh_token
      }
    else
      render json: { error: '無効なメールアドレスまたはパスワードです' }, status: :unauthorized
    end
  end

  private

  def generate_access_token(user)
    JWT.encode(
      {
        user_id: user.id,
        exp: 24.hours.from_now.to_i
      },
      Rails.application.credentials.devise_jwt_secret_key!
    )
  end

  def generate_refresh_token(user)
    JWT.encode(
      {
        user_id: user.id,
        exp: 30.days.from_now.to_i
      },
      Rails.application.credentials.devise_jwt_secret_key!
    )
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end