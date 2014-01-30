class BoardsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize

  def new
    @user = User.new
    @board = Demo.new
  end

  def create
    board_saved_successfully = nil
    user_saved_successfully = nil

    Demo.transaction do
      @board = Demo.new(name: params[:board][:name])
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
      
      user_saved_successfully = @user.save
    end

    if board_saved_successfully && user_saved_successfully
      @user.send_conversion_email
      sign_in(@user)
      redirect_to client_admin_tiles_path
    else
      set_errors
      render 'new'
    end
  end

  protected

  def set_board_defaults
    @board.game_referrer_bonus = 5
    @board.referred_credit_bonus = 2
    @board.credit_game_referrer_threshold = 100000
  end

  def set_errors
    # If you value your sanity, you won't read much further.
    # A form object might have been a good idea here, but I'm in a hurry
    # and I'm not sure this feature has a future.
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

    flash.now[:failure] = "Sorry, we weren't able to create your board: " + errors.join(', ') + '.'
  end
end
