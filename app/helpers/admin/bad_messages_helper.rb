module Admin::BadMessagesHelper
  def threaded_messages(thr)
    render_to_string(:template => 'admin/bad_messages/_thread', :locals => {:thread => thr})
  end
end
