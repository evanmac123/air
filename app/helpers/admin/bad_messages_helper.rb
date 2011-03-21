module Admin::BadMessagesHelper
  def reply_link(link_text, message)
    link_to link_text, new_admin_bad_message_reply_path(:bad_message_id => message.id), :class => 'reply-link', :id => reply_link_dom_id(message)
  end

  def reply_link_dom_id(message)
    "reply-link-#{dom_id(message)}"
  end
end
