class BoardsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize
  before_filter :allow_guest_user

  include NormalizeBoardName
  include BoardsHelper

  def new
    @user = User.new
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
      redirect_to client_admin_tiles_path
    else
      redirect_to :back
    end
  end

  def create_as_guest
    # If you value your sanity, you won't read much further.
    #
    # Though the situation here is better than it was since extracting the
    # CreateBoard service object.
  
    authorize_as_guest

    board_saved_successfully = nil
    user_saved_successfully = nil

    original_board_name = params[:board][:name]

    Demo.transaction do
      board_creator = CreateBoard.new(original_board_name)
      board_saved_successfully = board_creator.create
      @board = board_creator.board

      @user = @board.users.new(name: params[:user][:name], email: params[:user][:email])
      @user.creating_board = true
      @user.password = @user.password_confirmation = params[:user][:password]
      @user.is_client_admin = true
      @user.cancel_account_token = @user.generate_cancel_account_token(@user)
      @user.accepted_invitation_at = Time.now
      
      user_saved_successfully = @user.save

      unless board_saved_successfully && user_saved_successfully
        raise ActiveRecord::Rollback
      end
    end

    if board_saved_successfully && user_saved_successfully
      if current_user && current_user.is_guest?
        current_user.converted_user = @user
        current_user.save!

        @user.voteup_intro_seen = current_user.voteup_intro_seen
        @user.save!
      end

      @user.add_board(@board.id, true)
      @user.reload
      @user.send_conversion_email
      sign_in(@user, 1)
      schedule_creation_pings(@user)
      render_success
    else
      @board.name = original_board_name
      render_failure
    end
  end

  protected

  def render_success
    respond_to do |format|
      format.json { render json: {status: 'success'} }
      format.html { redirect_to client_admin_tiles_path }
    end
  end

  def render_failure
    respond_to do |format|
      format.json { render json: {status: 'failure', errors: set_errors} }
      format.html do
        if params[:page_name] == "welcome"
          redirect_to :controller => 'pages', \
                      :action => 'show', \
                      :id => "welcome", \
                      flash: { failure: set_errors }
        else
          flash.now[:failure] = set_errors
          render 'new'
        end
      end
    end
  end

  def set_board_defaults
    @board.game_referrer_bonus = 5
    @board.referred_credit_bonus = 2
    @board.credit_game_referrer_threshold = 100000
  end

  def set_errors
    errors = []

    @board.errors.each do |field, raw_error|
      case field.to_s
      when 'name'
        errors << "the board name " + raw_error
      end
    end

    @user.errors.each do |field, raw_error|
      case field.to_s
      when 'name'
        errors << "user name can't be blank"
      when 'email'
        errors << "user email " + raw_error
      when 'password'
        errors << raw_error
      end
    end

    "Sorry, we weren't able to create your board: " + errors.join(', ') + '.'
  end

  def schedule_creation_pings(user)
    ping 'Boards - New', {source: params[:creation_source_board]}, user
    ping 'Creator - New', {source: params[:creation_source_creator]}, user
  end

  def find_current_board
    Demo.new(is_public: true)
  end
end
