
class Admin::TopicBoardsController < AdminBaseController
  def index
    @topic_boards = TopicBoard.reference_board_set
    @demos = Demo.scoped  
    @topics = Topic.scoped
  end

  def new
  end
end
