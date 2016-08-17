#FIXME this entire logic needs to be completely rewritten. It is a utter cluster
#fuck.
class BoardsController < ApplicationController
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  include NormalizeBoardName
  include BoardsHelper

  def new
    @user = User.new(email: params[:email])
    @board = Demo.new
  end

  def create
    params[:as_existing] ? create_as_existing : create_as_guest
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
        truncatedUpdatedBoardName: truncate_name_for_switcher(@new_board_name)
      }
    else
      render json: {success: false, message: "Sorry, that board name is already taken."}
    end
  end

  protected

  def create_as_existing
    authorize
    return if response.redirect? # auth failed

    board_creator = CreateBoard.new(params[:board_name])
    if board_creator.create
      board = board_creator.board
      current_user.add_board(board)
      current_user.move_to_new_demo(board)
      current_user.is_client_admin = true
      current_user.save!
      BoardCreatedNotificationMailer.delay_mail(:notify, current_user.id, board.id)
      redirect_to client_admin_tiles_path
    else
      redirect_to :back
    end
  end

  def create_as_guest
    authorize_as_guest
    binding.pry
    login_as_guest(Demo.new) unless current_user.present?
    @create_user_with_board = CreateUserWithBoard.new params.merge(pre_user: current_user)
    success = @create_user_with_board.create
    @user = @create_user_with_board.user
    @board = @create_user_with_board.board

    if success
      sign_in(@user, 1)
      render_success
    else
      render_failure(@create_user_with_board.set_errors)
    end
  end

  private

  def render_success
    respond_to do |format|
      format.json { render json: {status: 'success'} }
      format.html { redirect_to post_creation_path }
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
          flash.now[:failure] = set_errors
          render 'new'
        end
      end
    end
  end

  def post_creation_path
    LIBRARY_ENABLED=="true" ? client_admin_stock_boards_path : client_admin_explore_path
  end

  def find_current_board
    Demo.new(is_public: true)
  end
end
