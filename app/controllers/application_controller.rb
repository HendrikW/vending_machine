class ApplicationController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound do |e|
    if e.model === "User"
      render json: { error: 'user not found' }, status: :not_found
    else
      render json: { error: 'not found' }, status: :not_found
    end
  end

  def not_found
    render html: '<html>Find API documentation under <a href="/docs">/docs</a>.</html>'.html_safe, status: 404
  end

  private

  def jwt_token(user)
    exp = Time.now.to_i + (20 * 60)  # 20 minutes
    payload = { user_id: user.id, role: user.role, exp: exp }
    JWT.encode payload, hmac_secret, 'HS256'
  end

  def hmac_secret
    ENV["API_SECRET_KEY"]
  end

  def client_has_valid_token?
    !!current_user_id
  end

  def current_token_payload
    begin
      token = request.headers["Authorization"]
      token.gsub!('Bearer ', '')
      decoded_array = JWT.decode token, hmac_secret, true
      payload = decoded_array.first
  rescue JWT::ExpiredSignature => e
    Rails.logger.warn "Token has expired: " + e.to_s
      return nil
  rescue JWT::DecodeError => e
    Rails.logger.warn "Error decoding the JWT: " + e.to_s
      return nil
  rescue 
    Rails.logger.warn "JWT Error: " + e.to_s
      return nil
    end
      payload
  end
    
  def current_user_id
    current_token_payload && current_token_payload['user_id']
  end

  def current_user
    @user ||= User.find(current_user_id)        
  end

  def current_user_role
    current_token_payload && current_token_payload['role']
  end

  def require_login
    render json: {error: 'Unauthorized'}, status: :unauthorized if !client_has_valid_token?
  end

  def user_is_buyer
    unless current_user_role === "buyer"
      render json: { message: 'only buyers can do this action' }, status: :unauthorized
    end
  end

  def user_is_seller
    unless current_user_role === "seller"
      render json: { message: 'only sellers can do this action' }, status: :unauthorized
    end
  end
end
