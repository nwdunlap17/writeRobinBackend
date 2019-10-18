class SubmissionSerializer < ActiveModel::Serializer
  attributes :id, :content, :user_id, :canon, :position, :score

  # def author
  #     return 'Test'
  #     #return User.find(object.user_id).username
  # end

  def score
    return object.tally_votes()
  end
end
