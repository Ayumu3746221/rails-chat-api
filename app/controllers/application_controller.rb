class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  private

  def authenticate_user!
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!)[0]
        
        # トークンの有効期限をチェック
        if token_expired?(decoded_token)
          if refresh_token = request.headers['Refresh-Token']
            # リフレッシュトークンを使用して新しいトークンを発行
            new_token = refresh_user_token(refresh_token)
            response.headers['New-Token'] = new_token if new_token
          end
          render json: { error: 'トークンの有効期限が切れています' }, status: :unauthorized
          return
        end
        
        @current_user_id = decoded_token['user_id']
      rescue JWT::DecodeError
        render json: { error: '無効なトークンです' }, status: :unauthorized
      end
    else
      render json: { error: '認証ヘッダーがありません' }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= User.find(@current_user_id)
  end

  private

  def token_expired?(decoded_token)
    exp = decoded_token['exp']
    exp.present? && Time.at(exp) < Time.current
  end

  def refresh_user_token(refresh_token)
    begin
      decoded_refresh = JWT.decode(refresh_token, Rails.application.credentials.devise_jwt_secret_key!)[0]
      user = User.find(decoded_refresh['user_id'])
      
      # 新しいトークンを生成
      JWT.encode(
        {
          user_id: user.id,
          exp: 24.hours.from_now.to_i
        },
        Rails.application.credentials.devise_jwt_secret_key!
      )
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end
end