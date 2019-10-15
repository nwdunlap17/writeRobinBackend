class Story < ApplicationRecord
    belongs_to :user
    has_many :submissions

    def check_for_promotion
        required = self.required_votes()
        promoted = self.submissions.where('CANON = false').find do |sub|
            sub.tally_votes >= required
        end

        # byebug
        if !!promoted
            # byebug
            return prepare_to_append_submission(promoted)
        end
        return nil
    end

    def prepare_to_append_submission(promoted)
        promoted.canon = true
        promoted.save
        # byebug
        self.submissions.each do |sub|
            if sub.canon == false && sub.id != promoted.id
                sub.destroy
            end
        end
        # byebug
        promoted.position = self.submissions.length
        
        self.round_unique_users = 0
        # byebug
        promoted.save
        self.save

        return promoted.story.id
    end

    def Story.broadcast_story_update(id)
        story = Story.find(id)
        entry = ActiveModel::SerializableResource.new(story)
        # byebug
        StoryChannel.broadcast_to(self, {message:'update',story:entry})
        
    end

    def increment_unique_voters?(userID)
        # byebug 
        if (!check_if_user_unique(userID))
            self.round_unique_users += 1
            self.save

        end
    end

    def check_if_user_unique(userID)
        self.submissions.where('CANON = false').each do |sub|
           if (!!sub.votes.find_by(user_id: userID))
                return false
            end
        end

        return true
    end

    def required_votes
        total = self.round_unique_users

        divisor = Math.log10(total) + 1.0
        fraction = 1/divisor
        
        required =  total * fraction
        # byebug
        if required < 3
            return 3
        else
            return required
        end
    end
    
end
