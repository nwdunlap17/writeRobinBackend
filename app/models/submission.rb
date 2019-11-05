class Submission < ApplicationRecord
    belongs_to :user
    belongs_to :story
    has_many :votes

    def tally_votes
        running_total = 0
        self.votes.each do |vote|
            if vote.positive
                running_total += 1
            else
                running_total -= 1
            end
        end
        return running_total
    end

    def receive_vote
        if (self.tally_votes >= 3)
                # byebug
            story = Story.find(self.story_id)
            return story.check_for_promotion()
        end
        return nil
    end

    def find_user_vote(userID)
        vote = self.votes.find_by(user_id: userID)
        if (vote == nil)
            return 0
        else
            if (vote.positive)
                return 1
            else
                return -1
            end
        end
    end


    def notify_users_followers_of_submission
        author = self.user
        followers = author.follows.map do |follow|
            User.find(follow.user_id)
        end

        invites = []
        if (self.story.public == false)
            invites.map! do |invite|
                invite.user.id
            end
        end

        followers.each do |profile|
            if(self.story.public)
                Notification.create(follow: true, user_id: profile.id, sender: 'System', content: "#{author.username} has made a new post in #{self.story.title}! http://writerobin.herokuapp.com/stories/#{self.story.id}" )
            else
                if(invites.include?(profile.id))
                    Notification.create(follow: true, user_id: profile.id, sender: 'System', content: "#{author.username} has made a new post in #{self.story.title}! http://writerobin.herokuapp.com/stories/#{self.story.id}" )
                end
            end
        end
    end
end
