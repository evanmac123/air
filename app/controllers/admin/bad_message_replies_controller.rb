class Admin::BadMessageRepliesController < AdminBaseController
  before_filter :find_bad_message

  def new
    @bad_message_reply = @bad_message.replies.new
  end

  def create
    reply = @bad_message.replies.build(params[:bad_message_reply])
    reply.sender = current_user
    
    if reply.save
      @sent = (Rails.env == 'development') || reply.send_to_bad_message_originator

      if @sent
        flash[:notice] = "Message sent to #{@bad_message.phone_number}"
        @bad_message.put_on_watch_list
      end
    else
      flash[:failure] = "Couldn't send message: #{reply.errors.full_messages.join(', ')}"
    end

    respond_to do |format|
      format.html {redirect_to admin_bad_messages_path}
      format.js
    end
  end

  protected

  def find_bad_message
    @bad_message = BadMessage.find(params[:bad_message_id], :include => :user)
  end
end
