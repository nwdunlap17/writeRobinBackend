class StorySerializer < ActiveModel::Serializer
  attributes :id, :submissions, :title, :length, :current_length, :genres, :invited

  def submissions      
      subs = object.submissions
      user_id = instance_options[:user_id]

      subs = subs.sort do |a,b|
        b.tally_votes <=> a.tally_votes
      end

      subs = subs.map do |sub|
        
        hash = sub.attributes
        hash[:author] = sub.user.username
        hash[:score] = sub.tally_votes
        if (!!user_id && user_id> 0)
          #0 if user hasn't voted on this sub, 1 for positive vote, -1 for negative vote
          hash[:vote] = sub.find_user_vote(user_id)
        end

        hash
      end

      return subs
  end

  def invited
    if(object.public == true)
      return []
    else
      return object.invitations.map do |invite|
          element = {username: invite.user.username, id: invite.user.id}
      end
    end

  end
end

class GroupStorySerializer < ActiveModel::Serializer
  attributes :id, :title, :length, :current_length, :score, :genres
end