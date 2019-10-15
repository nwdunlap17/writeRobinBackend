class StoriesController < ApplicationController

    skip_before_action :authorized, only: [:view, :index, :public_index]
    
    def index
        @stories = Story.all
        render json: @stories
    end

    def public_index
        @story = Story.where('PUBLIC = true')
        render json: @story, each_serializer: GroupStorySerializer
    end

    def create
        @authorID = get_user_from_token
        if @authorID > 0 
            params[:story][:user_id] = @authorID
            @story = Story.create(story_params)
            @submission = Submission.create(content: params[:content], user_id: @authorID, story_id: @story.id, position: 1, canon: true)
            @story.submissions << @submission
            byebug
            render :json => {story_id: @story.id}
        else
            byebug
        end
    end

    def view
        @story = Story.find(params[:id])

        user = get_user_from_token
        # byebug

        # For private stories, check for access here
        
        entry = ActiveModel::SerializableResource.new(@story)
        
        # @story.new_viewer(1)
        render json: @story, user_id: user
    end

    def append
        toAdd = params[:addend]
        @story = Story.find(params[:id])
        @story.content += " " + toAdd
        @story.save



        render :json => {message: 'done'}
    end

    private

    def story_params
        params.require(:story).permit(:title, :public, :user_id)
    end

    protected

    def json_request? 
        return request.format.json?
    end
end
