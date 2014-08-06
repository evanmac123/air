class BoardsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize

  def new
    @user = User.new
    @board = Demo.new
  end

  def create
    # If you value your sanity, you won't read much further.
    # A form object might have been a good idea here, but I'm in a hurry
    # and I'm not sure this feature has a future.
    #
    # Sue me.
    
    board_saved_successfully = nil
    user_saved_successfully = nil

    original_board_name = params[:board][:name]
    Demo.transaction do
      _board_name = original_board_name
      unless _board_name.blank? || _board_name.downcase.split.last == 'board'
        _board_name += " Board"
      end

      @board = Demo.new(name: _board_name)

      set_board_defaults
      board_saved_successfully = @board.save
      # We do this separately so that we know the board has a unique public slug

      if board_saved_successfully
        email_local_part = @board.public_slug.gsub(/-/, '')
        @board.update_attributes(email: email_local_part + "@ourairbo.com")
      end

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
end
