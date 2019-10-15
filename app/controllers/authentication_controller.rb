class AuthenticationController < ApplicationController
  # skip_before_action :verify_authenticity_token, if: :json_request?
   before_action :authorized, except: :login

  # POST /auth/login
  def login
    @user = User.find_by(username: params[:username])
    # byebug
    if @user&.authenticate(params[:password])
    # byebug
      token = JWT.encode({user_id: @user.id},'secret')
      # time = Time.now + 24.hours.to_i
      # byebug
      render json: { token: token, username: @user.username }, status: :ok
    
    else
    byebug
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:username, :password)
  end

    protected

    def json_request? 
        return request.format.json?
    end
end
