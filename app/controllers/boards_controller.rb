#FIXME this entire logic needs to be completely rewritten. It is a utter cluster
#fuck.
class BoardsController < UserBaseController
  layout 'external'
  layout 'standalone', only: [:new]

  include NormalizeBoardName
  include BoardsHelper

  def new
    @user = User.new(email: params[:email])
    @board = Demo.new
  end

  def create
    board_creator = CreateBoard.new(params[:board_name])
    if board_creator.create
      board = board_creator.board
      current_user.add_board(board, { is_current: false, is_client_admin: true })
      current_user.move_to_new_demo(board)
      BoardCreatedNotificationMailer.notify(current_user.id, board.id).deliver_later
      redirect_to client_admin_tiles_path
    else
      redirect_to :back
    end
  end

  def update
    board = Demo.find(params[:id])

    unless current_user.is_client_admin_in_board(board) || current_user.is_site_admin
      render nothing: true
      return
    end

    @new_board_name = normalize_board_name(params[:board_name])
    board.name = @new_board_name

    if board.save
      render json: {
        success: true,
        updatedBoardName: @new_board_name,
      }
    else
      render json: {success: false, message: "Sorry, that board name is already taken."}
    end
  end

  private

    def render_success
      respond_to do |format|
        format.json { render json: {status: 'success'} }
        format.html { redirect_to explore_path }
      end
    end

    def render_failure(set_errors)
      respond_to do |format|
        format.json { render json: {status: 'failure', errors: set_errors} }
        format.html do
          if params[:page_name] == "welcome"
            redirect_to :controller => 'pages', \
                        :action => 'show', \
                        :id => "home", \
                        flash: { failure: set_errors }
          elsif params[:page_name] == "product"
            redirect_to :controller => 'pages', \
                        :action => 'product', \
                        flash: { failure: set_errors }
          else
            flash[:failure] = set_errors
            redirect_to "/join"
          end
        end
      end
    end
end
