class SubmissionSerializer < ActiveModel::Serializer
  #This is not actually being used right now, checkout the submissions function in story_serializer
  attributes :id, :content, :user_id, :canon, :position, :score, :author

  def author
      return User.find(object.user_id).username
  end

  def score
    return object.tally_votes()
  end
end
