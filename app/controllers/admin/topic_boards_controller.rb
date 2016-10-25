
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
    if @topic_board.valid?
      flash[:success]="Topic Board Created Successfully"
      redirect_to admin_topic_boards_path
    else
      flash[:failure]=@topic_board.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def permitted_params
   params.require(:topic_board).permit(:topic_id, :demo_id, :is_reference, :is_library, :is_onboarding, :cover_image)
  end

  def resources
    @demos = Demo.name_order.select([:name, :id])
    @topics = Topic.scoped.select([:name, :id])
  end
end
