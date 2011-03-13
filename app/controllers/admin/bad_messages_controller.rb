class Admin::BadMessagesController < AdminBaseController
  def index
    @threads = BadMessageThread.most_recent_first.all(:include => {:messages => [:user, {:replies => :sender}]})
  end
end
