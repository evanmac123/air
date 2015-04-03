class CreateUserWithBoard
  attr_reader :user, :board

  def initialize params
    @board_name = params[:board][:name] 
    @user_name  = params[:user][:name]
    @email      = params[:user][:email]
    @password   = params[:user][:password]
    @pre_user   = params[:pre_user]
    @creation_source_board = params[:creation_source_board]
    @creation_source_creator = params[:creation_source_creator]
  end

  def create
    ActiveRecord::Base.transaction do
      create_board
      create_user
      
      unless success?
        raise ActiveRecord::Rollback
      end
    end

    if success?
      send_notification_email
      schedule_creation_pings
    else
      @board.name = @board_name
    end
    success?
  end

  def set_errors
    @error_message ||= begin 
      errors = []
      errors.concat board_errors
      errors.concat user_errors
      "Sorry, we weren't able to create your board: " + errors.join(', ') + '.'
    end
  end

  protected
  #
  # => Board Creation
  #
  def create_board
    @board_saved_successfully = board_creator.create
    @board = board_creator.board
  end

  def board_creator
    @board_creator ||= CreateBoard.new(@board_name)
  end
  #
  # => User Creation
  #
  def create_user
    @user_saved_successfully = user_creator.create_client_admin_with_board! @board
    @user = user_creator.converted_user
  end

  def user_creator
    @user_creator ||= ConvertToFullUser.new({
      pre_user:              @pre_user, 
      name:                  @user_name, 
      email:                 @email, 
      password:              @password,
      converting_from_guest: true
    })
  end
  #
  # => Errors
  #
  def board_errors
    errors = []
    @board.errors.each do |field, raw_error|
      case field.to_s
      when 'name'
        errors << "the board name " + raw_error
      end
    end
    errors
  end

  def user_errors
    errors = []
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
    errors
  end

  def success?
    @board_saved_successfully && @user_saved_successfully
  end

  def send_notification_email
    BoardCreatedNotificationMailer.delay_mail(:notify, @user.id, @board.id)
  end

  def schedule_creation_pings
    TrackEvent.ping 'Boards - New',  {source: @creation_source_board},   @user
    TrackEvent.ping 'Creator - New', {source: @creation_source_creator}, @user
  end
end