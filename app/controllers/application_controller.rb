class ApplicationController < ActionController::API
  before_action :authorized
 
  def get_user_from_token
      token = auth_header.split(' ')[1]
      if token != 'null'
        result = JWT.decode(token, 'secret', true, algorithm: 'HS256')
        
        result[0]['user_id']
      else
        0
      end
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end
 
  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      # header: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, 'secret', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end
 
  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end
 
  def logged_in?
    !!current_user
  end
 
  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end