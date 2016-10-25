
class Admin::TopicBoardsController < AdminBaseController
  before_filter :resources, except:[:index]

  def index
    @topic_boards = TopicBoard.scoped
  end

  def new
    @topic_board = TopicBoard.new
  end

  def edit
    @topic_board = TopicBoard.find(params[:id])
  end


  def update
    @topic_board = TopicBoard.find(params[:id])
    if @topic_board.update_attributes(permitted_params)
      redirect_to admin_topic_boards_path
    else
     render :edit
    end
  end

  def create
    @topic_board = TopicBoard.create(permitted_params)
    @topic_board.board.update_attributes({ is_parent: true, is_public: true })
    if @topic_board.valid?
      flash[:success]="Topic Board Created Successfully"
      redirect_to admin_topic_boards_path
    else
      flash[:failure]=@topic_board.errors.full_messages.to_sentence
      render :new
    end
  end

  def destroy
    topic_board = TopicBoard.find(params[:id]).destroy
    flash[:success] = "#{topic_board.board.name} removed from Library and Onboarding."
    redirect_to admin_topic_boards_path
  end

  private

    def permitted_params
      params.require(:topic_board).permit(
        :topic_id,
        :demo_id,
        :is_reference,
        :is_library,
        :is_onboarding,
        :cover_image
      )
    end

    def resources
      @demos = Demo.name_order.select([:name, :id])
      @topics = Topic.scoped.select([:name, :id])
    end
end
