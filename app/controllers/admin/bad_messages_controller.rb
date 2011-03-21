class Admin::BadMessagesController < AdminBaseController
  include Admin::BadMessagesHelper

  def index
    @new_messages = BadMessage.new_messages.most_recent_first.include_user
    @watch_listed_messages = BadMessage.watch_listed.most_recent_first.include_user.include_replies
    @needing_reply_count = BadMessage.watch_listed.without_replies.count
    @all_messages = BadMessage.most_recent_first.include_user.include_replies
  end

  def update
    @message = BadMessage.find(params[:id])
    @message.update_attributes(params[:message])
    redirect_to admin_bad_messages_path
  end
end
