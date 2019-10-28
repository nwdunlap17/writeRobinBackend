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
        puts 'XJ9'
        @user = User.find(params[:id])
        currentUserID = get_user_from_token
        puts "Current User ID is #{currentUserID}"
        

        if @user.id == currentUserID
            #self
            render :json => {username:@user.username, id:@user.id, friends: User.find(currentUserID).friends}
        else
            #other user
            isFriends = false

            if (currentUserID != 0)
                currentUser = User.find(currentUserID)
                isFriends = currentUser.is_friends_with(params[:id])
            end

            render :json => {username:@user.username, id:@user.id , friended: isFriends}
        end
    end

    def friend
        friender = User.find(get_user_from_token)
        to_friend = User.find(params[:id].to_i)

        if (!friender.is_friends_with(params[:id].to_i))
            Notification.new(invite: true, sender: friender, user: to_friend, content: "#{friender.username} wants to be your friend!")
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

    def get_messages
        user = get_user_from_token
        if user != 0
            render json: User.find(user).notifications
        else
            render :json => {message: 'not authorized'}
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
