class SubmissionsController < ApplicationController
    skip_before_action :authorized, only: :index
    def index
        @subs = Submission.all 
        render json: @subs

    end

    def create
        user = get_user_from_token
        @submit = Submission.new(sub_params)        
        @submit.user_id = user
        @submit.save
        @story   = Story.find(params[:submission][:story_id])

        StoryChannel.broadcast_to(@story, {message:'submission',submission:@submit})
        render :json => {foo: 'bar'}
    end

    def vote
        @user_id = get_user_from_token
        @submission = Submission.find( params[:submission_id] )
        
        if params[:value] != 0 
            positivity = params[:value] == 1? true : false
        # byebug
        
            @vote = @submission.votes.find_by(user_id: @user_id)
            @story = @submission.story
            if (!!@vote)
                @vote.positive = positivity
                @vote.save
            
            else
                @submission.story.increment_unique_voters?(@user_id)
                @vote = Vote.create(submission_id: @submission.id, user_id: @user_id, positive: positivity)   
            end

            if(positivity)
                foo = @submission.receive_vote()

                if (!!foo)
                    @story = Story.find(foo)
                    entry = ActiveModel::SerializableResource.new(@story)
                    StoryChannel.broadcast_to(@story, {message:'update',story:entry})
                end
            end
        else
            @vote = @submission.votes.find_by(user_id: @user_id)
            @vote.destroy   
        end

        render :json => {message: 'vote successful'}
    end

    private

    def sub_params
        params.require(:submission).permit(:content,:story_id)
    end
end
