class SubmissionSerializer < ActiveModel::Serializer
  attributes :id, :content, :user_id, :canon, :position, :author, :score

  def author
      return User.find(object.user_id).username
  end

  def score
    return 12#object.tally_votes
  end
end
