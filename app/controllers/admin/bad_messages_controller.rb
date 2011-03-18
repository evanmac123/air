class Admin::BadMessagesController < AdminBaseController
  include Admin::BadMessagesHelper

  def index
    thread_options = {:include => {:messages => [:user, {:replies => :sender}]}}

    if params[:since]
      thread_options[:conditions] = ['updated_at > ?', params[:since]]
    end

    @threads = BadMessageThread.most_recent_first.all(thread_options)
    @last_updated_at = @threads.first ? @threads.first.updated_at.with_us : Time.zone.now.utc.with_us

    respond_to do |format|
      format.html

      format.js 
    end
  end
end
