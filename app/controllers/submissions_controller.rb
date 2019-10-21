class SubmissionsController < ApplicationController
    skip_before_action :authorized, only: :index
    def index
        @subs = Submission.all 
        render json: @subs

    end

    def create
        @story   = Story.find(params[:submission][:story_id])
        if (@story.length != @story.current_length)
            user = get_user_from_token
            @submit = Submission.new(sub_params)        
            @submit.user_id = user
            @submit.save


            Vote.create(submission_id: @submit.id, user_id: user, positive: true)   

            StoryChannel.broadcast_to(@story, {message:'submission',submission:@submit,author:User.find(user).username})
        end
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
            @story.decrement_unique_voters?(@user_id)
        end

        render :json => {message: 'vote successful'}
    end

    def destroy
        @userID = get_user_from_token.to_i
        @submission = Submission.find(params[:id].to_i)
        @story = Story.find(@submission.story_id)
        if( @submission.user_id.to_i == @userID || User.find(userID).admin)
            @submission.destroy
            StoryChannel.broadcast_to(@story, {message:'delete submission', id: params[:id]})
        end
        render :json => {status: 'complete'}
    end

    private

    def sub_params
        params.require(:submission).permit(:content,:story_id)
    end
end
