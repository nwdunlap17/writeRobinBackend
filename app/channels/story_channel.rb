class StoryChannel < ApplicationCable::Channel

  def subscribed
    @story = Story.find_by(id: params[:id])
    
    stream_for @story
  end

  def received(data)
    byebug
    StoryChannel.broadcast_to(@story, {story: @story, message: 'Hello There!'})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
