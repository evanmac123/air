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
    authorize_as_guest
    login_as_guest(Demo.new) unless current_user.present?

    pre_user = current_user

    success = nil
    original_board_name = params[:board][:name]

    ActiveRecord::Base.transaction do
      board_creator = CreateBoard.new(original_board_name)
      board_saved_successfully = board_creator.create
      @board = board_creator.board

      user_creator = ConvertToFullUser.new({
        pre_user:              current_user, 
        name:                  params[:user][:name], 
        email:                 params[:user][:email], 
        password:              params[:user][:password],
        converting_from_guest: true
      })
      user_saved_successfully = user_creator.create_client_admin_with_board! @board
      @user = user_creator.converted_user

      success = board_saved_successfully && user_saved_successfully
      unless success
        raise ActiveRecord::Rollback
      end
    end

    if success
      sign_in(@user, 1)
      schedule_creation_pings(@user)
      alias_guest_user_mixpanel_id_to_client_admin_mixpanel_id(pre_user, @user)
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
      format.html { redirect_to client_admin_explore_path }
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

  def alias_guest_user_mixpanel_id_to_client_admin_mixpanel_id(pre_user, post_user)
    tracker = Mixpanel::Tracker.new(MIXPANEL_TOKEN, {})
    debugger
    tracker.alias(post_user.mixpanel_distinct_id, pre_user.mixpanel_distinct_id) 
  end
end
