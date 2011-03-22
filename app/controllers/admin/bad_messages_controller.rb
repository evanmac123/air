class Admin::BadMessagesController < AdminBaseController
  include Admin::BadMessagesHelper

  def index
    @new_messages = BadMessage.new_messages.not_watch_listed.most_recent_first.include_user
    @watch_listed_messages = BadMessage.watch_listed.most_recent_first.include_user.include_replies

    respond_to do |format|
      format.html do
        @needing_reply_count = BadMessage.watch_listed.without_replies.count
        @all_messages = BadMessage.most_recent_first.include_user.include_replies
        @newest_message_id = @all_messages.first.id
      end

      format.js do
        old_newest_message = BadMessage.find(params[:newest_message_id])
        @new_messages = @new_messages.where('received_at > ?', old_newest_message.received_at)
        @watch_listed_messages = @watch_listed_messages.where('received_at > ?', old_newest_message.received_at)

        @all_messages = @new_messages + @watch_listed_messages

        if @all_messages.empty?
          newest_message = old_newest_message
        else
          newest_message = (@all_messages).max_by(&:received_at)
        end

        @newest_message_id = newest_message.id
      end
    end
  end

  def update
    @message = BadMessage.find(params[:id])
    @message.update_attributes(params[:message])

    respond_to do |format|
      format.html {redirect_to admin_bad_messages_path}
      format.js
    end
  end
end
