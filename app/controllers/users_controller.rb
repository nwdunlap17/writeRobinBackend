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
        puts "Current User ID is #{currentUserID}"
        
        numFollowers = Follow.all.select do |follow|
            follow.following == @user
            # (follow.following_id == @user.id) && (following_type == 'User')
        end
        numFollowers = numFollowers.count
        puts "Has #{numFollowers} Followers"

        if @user.id == currentUserID
            #self
            render :json => {username:@user.username, id:@user.id, friends: User.find(currentUserID).friends, numFollowers: numFollowers}
        else
            #other user
            isFriends = false

            if (currentUserID != 0)
                currentUser = User.find(currentUserID)
                isFriends = currentUser.is_friends_with(params[:id])
                isFollowing = currentUser.is_following_user(params[:id])
            end

            render :json => {username:@user.username, id:@user.id , friended: isFriends, following: isFollowing, numFollowers: numFollowers}
        end
    end

    def friend
        friender = User.find(get_user_from_token)
        to_friend = User.find(params[:id].to_i)

        if (!friender.is_friends_with(params[:id].to_i))
            Notification.new(invite: true, sender: friender, user_id: to_friend.id, content: "#{friender.username} wants to be your friend!")
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

    def send_message
        puts "The params"
        puts params
        @user = User.find(get_user_from_token)
        @recipient = User.find(params[:id])
        @message = Notification.new(user_id: @recipient.id, sender: @user,content: params[:content])
        @message.save
    end

    def get_messages
        user = get_user_from_token
        if user != 0
            messages = User.find(user).notifications.reverse
            messages.each do |note|
                note.read = true
                note.save
            end
            render json: messages
        else
            render :json => {message: 'not authorized'}
        end
    end

    def follow
        user = get_user_from_token
        be_followed = User.find(params[:id].to_i)
        if (user != 0)
            alreadyFollowing = be_followed.follows.map do |follow|
                follow.user_id
            end
            if (!alreadyFollowing.include?(user))
                Follow.create(user_id: user, following: be_followed)
            end
        end
    end

    def unfollow
        puts "UNFOLLOW"
        user = get_user_from_token
        be_followed = User.find(params[:id].to_i)
        if (user != 0)
            alreadyFollowing = be_followed.follows.map do |follow|
                follow.user_id
            end
            puts "ALREADY FOLLOWING #{alreadyFollowing}"
            if (alreadyFollowing.include?(user))
                puts "ALREADY FOLLOWING DOES INCLUDE USER"
                instance = Follow.find_by(user_id:user, following:be_followed)
                puts "ITS ID IS #{instance.id}"
                instance.delete
            end
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
