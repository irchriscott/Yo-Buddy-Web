class CommentChannel < ApplicationCable::Channel

    def self.broadcast(comment)
		    broadcast_to comment.item, comment:
		    CommentsController.render(partial: "comments/comment", locals: {comment: comment})
    end

  	def subscribed
      item = Item.find(params[:id])
    	stream_for item
  	end

  	def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  	end
end
