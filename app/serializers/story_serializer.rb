

class StorySerializer < ActiveModel::Serializer
  attributes :id, :submissions, :title

  def submissions      
      subs = object.submissions
      user_id = instance_options[:user_id]

      subs = subs.map do |sub|
        
        hash = sub.attributes
        hash[:author] = sub.user.username
        
        if (!!user_id && user_id> 0)
          #0 if user hasn't voted on this sub, 1 for positive vote, -1 for negative vote
          hash[:vote] = sub.find_user_vote(user_id)
        end

        hash
      end

      return subs
  end
end

class GroupStorySerializer < StorySerializer
  attributes :id, :title
end