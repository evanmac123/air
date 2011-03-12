class Admin::BadMessageRepliesController < AdminBaseController
  before_filter :find_bad_message

  def new
    @bad_message_reply = @bad_message.replies.new
  end

  def create
    reply = @bad_message.replies.build(params[:bad_message_reply])
    reply.sender = current_user
    
    if reply.save
      if reply.send_to_bad_message_originator
        flash[:notice] = "Message sent to #{@bad_message.phone_number}"
      end
    else
      flash[:failure] = "Couldn't send message: #{reply.errors.full_messages.join(', ')}"
    end

    redirect_to admin_bad_messages_path
  end

  protected

  def find_bad_message
    @bad_message = BadMessage.find(params[:bad_message_id])
  end
end
