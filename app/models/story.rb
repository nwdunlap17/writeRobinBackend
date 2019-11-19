class Story < ApplicationRecord
    belongs_to :user
    has_many :submissions
    has_many :genre_tags
    has_many :genres, through: :genre_tags
    has_many :invitations
    has_many :follows, foreign_key: "following_id"

    def canon
        return self.submissions.where('CANON = true')
    end

    def score
        total = 0
        self.canon.each do |part|
            total += part.tally_votes
        end
        return total
    end

    def current_length
        return self.canon.length
    end

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
        setToPosition = 1
        self.submissions.each do |sub|
            if sub.canon == false && sub.id != promoted.id
                sub.destroy
            end
            if sub.canon == true
                setToPosition += 1
            end
        end
        # byebug
        
        promoted.position = setToPosition
        
        self.round_unique_users = 0
        # byebug
        promoted.save
        self.save

        notify_followers_of_update()

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
        if (check_if_user_unique(userID))
            self.round_unique_users += 1
            self.save
        end
    end

    def decrement_unique_voters?(userID)
        # If the user no longer exists, decrement the vote
        if (!check_if_user_unique(userID))
            self.round_unique_users -= 1
            self.save
        end
    end

    def check_if_user_unique(userID)
        self.submissions.where('CANON = false').each do |sub|
           if (!!sub.votes.find_by(user_id: userID) || sub.user_id == userID)
                return false
            end
        end

        return true
    end

    def required_votes

        minimum = 3
        if (self.public == false && self.invitations.count <= 2)
            minimum = self.invitations.count
        end

        total = self.round_unique_users

        divisor = Math.log10(total) + 1.0
        fraction = 1/divisor
        
        #On the fly adjustment
        fraction = fraction * 0.75

        required =  total * fraction

        if required < minimum
            return minimum
        else
            return required
        end
    end
    
    def unique_user_recount
        hash = {}
        self.submissions.where('CANON = false').each do |sub|
            hash[sub.user_id] = true;
            sub.votes.each do |vote|
                hash[vote.user_id] = true;
            end
        end
        self.round_unique_users = hash.keys.length
        self.save
    end

    def notify_followers_of_update
        followers = self.follows.map do |follow|
            User.find(follow.user_id)
        end
        followers.each do |profile|
            Notification.create(follow: true, user: profile.id, sender: 'System', content: "#{self.title} has been updated! http://writerobin.herokuapp.com/stories/#{self.id}" )
        end
    end
end 