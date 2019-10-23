class UsersController < ApplicationController
    # skip_before_action :verify_authenticity_token, if: :json_request?
    skip_before_action :authorized, only: [:create, :profile]

    def create
        @user = User.new(user_params)
        if @user.save
            token = JWT.encode({user_id: @user.id},'5KgjiJMXTmi0jvOzwfsp')
            render json: { token: token, username: @user.username, id:@user.id, message:'success'}, status: :ok
        else
            # byebug
            render :json => {message: 'failure'}
        end
    end

    def profile
        @user = User.find(params[:id])
        currentUserID = get_user_from_token

        if @user.id == currentUserID
            #self
            render :json => {username:@user.username, id:@user.id, friends: User.find(currentUserID).friends}
        else
            #other user
            currentUser = User.find(currentUserID)
            isFriends = currentUser.is_friends_with(params[:id])

            render :json => {username:@user.username, id:@user.id , friended: isFriends}
        end

    end

    def friend
        friender = User.find(get_user_from_token)
        to_friend = User.find(params[:id].to_i)

        if (!friender.is_friends_with(params[:id].to_i))
            Friendship.create(user1: friender.id, user2: to_friend.id)
        end
        render :json => {message: 'done'}
    end

    def unfriend
        friender = User.find(get_user_from_token)
        to_friend = User.find(params[:id].to_i)

        if (friender.is_friends_with(params[:id].to_i))
            Friendship.where('(USER1 = ? or USER2 = ?) and (USER1 = ? or USER2 = ?)',friender.id,friender.id,to_friend.id,to_friend.id)[0].destroy
        end
        render :json => {message: 'done'}

    end

    def friend_search
        @user = User.find(get_user_from_token)
        search = params[:search].downcase
        
        puts @user.username
        puts "friends: #{@user.friends}"

        results = @user.friends.filter do |friend|
            puts "#{friend[:username]} includes #{search}?"
            friend[:username].downcase.include?(search)
        end

        render :json => {results: results}
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
