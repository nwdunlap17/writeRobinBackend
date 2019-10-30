class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :sender, :sender_id, :content, :invite, :follow, :read
end
