class Admin::BadMessagesController < AdminBaseController
  def index
    @messages = BadMessage.most_recent_first.all(:include => [:user, {:replies => :sender}])
  end
end
