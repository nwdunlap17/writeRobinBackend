class SubmissionSerializer < ActiveModel::Serializer
  attributes :id, :content, :user_id, :canon, :position, :author

  def author
      return User.find(object.user_id).username
  end
end
