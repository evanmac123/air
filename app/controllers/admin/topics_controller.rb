class Admin::TopicsController < ApplicationController
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

  private

    def topic_params
      params.require(:topic).permit(:name, :is_explore, :cover_image)
    end
end
