class SearchController < ApplicationController

    def search
        term = params[:search].downcase

        if params[:category] == 'story'
            @stories = Story.where('PUBLIC = true').to_a
            
            user_id = get_user_from_token

            if (user_id > 0)
                user = User.find(user_id)

                user.invitations.each do |invite|
                    @stories << (Story.find(invite.story_id))
                end
            end

            @stories.filter do |story|
                story.title.downcase.include?(term)
            end

            @stories = @stories.sort do |a,b|
                b.score <=> a.score
            end
            render json: @stories, each_serializer: GroupStorySerializer
        elsif params[:category] == 'user'
            @users = User.all.filter do |user|
                user.username.downcase.include?(term)
            end
            render json: @users
        else
            render :json => {message: 'something went wrong'}
        end
    end
end
