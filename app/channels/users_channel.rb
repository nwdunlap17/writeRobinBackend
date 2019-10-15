class UsersChannel < ApplicationCable::Channel
  def subscribed
    @user = User.find_by(id: params[:user])
    stream_for @user
  end

  def received(data)
    UsersChannel.broadcast_to(@user, {user: @user, message: 'Hello There!'})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
