class StoriesController < ApplicationController

    skip_before_action :authorized, only: [:view, :index, :public_index, :getGenres]
    
    def index
        @stories = Story.all
        render json: @stories
    end

    def public_index
        @stories = Story.where('PUBLIC = true').to_a
        
        user_id = get_user_from_token

        if (user_id > 0)
            user = User.find(user_id)

            user.invitations.each do |invite|
                @stories << (Story.find(invite.story_id))
            end
        end

        @stories = @stories.sort do |a,b|
            b.score <=> a.score
        end
        render json: @stories, each_serializer: GroupStorySerializer
    end

    def getGenres
        @genres = Genre.all.filter do |genre|
            genre.name != 'Private'
        end

        render :json => {genres: @genres}
    end

    def create
        @authorID = get_user_from_token
        if @authorID > 0 
            params[:story][:user_id] = @authorID
            @story = Story.create(story_params)
            @submission = Submission.create(content: params[:content], user_id: @authorID, story_id: @story.id, position: 1, canon: true)
            Vote.create(submission_id: @submission.id, user_id: @authorID, positive: true)   
            @story.submissions << @submission
            params[:story][:genres].each do |genre|
                GenreTag.create(story_id: @story.id, genre_id: genre)
            end
            if (!@story.public)
                GenreTag.create(story_id: @story.id, genre_id:6)
                Invitation.create(story_id: @story.id, user_id: @authorID)
                params[:invites].each do |invite|
                    Invitation.create(story_id: @story.id, user_id: invite)
                end
            end
            render :json => {story_id: @story.id}
        else
            # byebug
        end
    end

    def view
        @story = Story.find(params[:id])

        user = get_user_from_token
        # byebug

        # For private stories, check for access here
        # entry = ActiveModel::SerializableResource.new(@story)

        if (@story.public)
            render json: @story, user_id: user
        else
            invited = @story.invitations.map do |invite|
                invite.user_id
            end

            if(invited.include?(user))
                render json: @story, user_id: user
            else
                render :json => {message: 'denied'}
            end
        end
        
        
        # @story.new_viewer(1)
    end

    def append
        toAdd = params[:addend]
        @story = Story.find(params[:id])
        @story.content += " " + toAdd
        @story.save

        render :json => {message: 'done'}
    end

    def newInvites
        puts 'HIT NEW INVITES'
        user = get_user_from_token
        @story = Story.find(params[:id])
        if (@story.public == false)
            puts 'STORY IS PRIVATE'
            userlist = @story.invitations.map do |user|
                user.id
            end
            if(userlist.include?(user))
                puts 'ACCESS ALLOWED'
                params[:invites].each do |invite|
                    userlist << invite.to_i
                    Invitation.create(story_id: @story.id, user_id:invite.to_i)
                end
            else
                 puts "ACCESS DENIED #{user} not in #{userlist}"

            end
        else
            puts 'STORY IS PUBLIC'
        end

            newUsers = @story.invitations.map do |invite|
                id = invite.user_id
                hash = {username: User.find(id).username, id: id}
            end

            render :json => {invited: newUsers}
    end

    private

    def story_params
        params.require(:story).permit(:title, :public, :user_id, :length)
    end
end
