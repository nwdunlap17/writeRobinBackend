class UsersController < ApplicationController
    # skip_before_action :verify_authenticity_token, if: :json_request?
    skip_before_action :authorized, only: [:create]

    def create
        @user = User.new(user_params)
        if @user.save
            token = JWT.encode({user_id: @user.id},'5KgjiJMXTmi0jvOzwfsp')
            render json: { token: token, username: @user.username, message:'success'}, status: :ok
        else
            # byebug
            render :json => {message: 'failure'}
        end
    end

    def profile
        puts 'USER PROFILE'
        @user = User.find(params[:id])
        currentUserID = get_user_from_token

        if @user.id == currentUserID
            puts 'CURRENT USER'
            #self
            render :json => {username:@user.username, id:@user.id, friends: currentUserID.friends}
        else
            puts 'OTHER USER'
            #other user
            isFriends = false
            currentUserID.friends.each do |friend|
                if friend.id == @user.id
                    isFriends = true
                    break
                end
            end
            puts 'HANDLED FRIENDS'
            render :json => {username:@user.username, id:@user.id , friended: isFriends}
        end

    end

    private

    def user_params 
        params.require(:user).permit(:username,:password)
    end

    # protected

    def json_request? 
        return request.format.json?
    end
end
