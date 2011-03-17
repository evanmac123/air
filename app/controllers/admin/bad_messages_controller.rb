class Admin::BadMessagesController < AdminBaseController
  include Admin::BadMessagesHelper

  def index
    thread_options = {:include => {:messages => [:user, {:replies => :sender}]}}

    if params[:since]
      thread_options[:conditions] = ['updated_at > ?', params[:since]]
    end

    @threads = BadMessageThread.most_recent_first.all(thread_options)
    @last_updated_at = @threads.first.updated_at

    respond_to do |format|
      format.html

      format.json do
        thread_content = @threads.map {|thr| threaded_messages(thr)}
        render json: {
          'last_updated_at' => @last_updated_at,
          'updated_threads' => thread_content
        }

        debugger
      end
    end
  end
end
