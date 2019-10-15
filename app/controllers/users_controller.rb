class UsersController < ApplicationController
    # skip_before_action :verify_authenticity_token, if: :json_request?
    skip_before_action :authorized, only: [:create]

    def create
        @user = User.new(user_params)
        if @user.save
            render json: @user
        else
            byebug
            render :json => {message: 'failure'}
        end
    end

    private

    def user_params 
        params.require(:user).permit(:username,:password)
    end

    protected

    def json_request? 
        return request.format.json?
    end
end
