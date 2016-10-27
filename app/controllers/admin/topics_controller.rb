class Admin::TopicsController < AdminBaseController
  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params)

    if @topic.save
      flash[:success] = "#{@topic.name} has been created."
      redirect_to new_admin_topic_path
    else
      flash[:failure] = "Couldn't create topic: #{@topic.errors.full_messages.join(', ')}"
    end
  end

  def index
    @topics = Topic.scoped
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(topic_params)
      redirect_to admin_topics_path
    else
     render :edit
    end
  end


  private

    def topic_params
      params.require(:topic).permit(
        :name,
        :is_explore,
        :cover_image
      )
    end
end
