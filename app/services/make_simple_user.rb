class MakeSimpleUser
  attr_reader :user_params, :demo, :email, :role, :existing_user, :current_user

  def initialize user_params, demo, current_user, user = nil
    @email = user_params[:email]
    @role = user_params.delete(:role)
    @user_params = user_params
    @demo = demo
    @current_user = current_user
    @existing_user = set_existing_user
    @user = user if user
  end

  def update
    role_was_changed = (role != user.role_in(demo))
    user.attributes = user_params
    set_phone_number

    user_saved = user.save
    if user_saved
      set_role
      ping_if_made_client_admin(user, role_was_changed)
    end
    user_saved
  end

  def existing_user_in_board?
    !is_new_user && existing_user.in_board?(demo)
  end

  def create
    user_saved = user.save
    if user_saved
      user.add_board(demo.id, is_new_user)
      set_role
      user.generate_unique_claim_code! unless user.claim_code.present?

      ping_if_made_client_admin(user, user.is_client_admin)
    end
    user_saved
  end

  def user_errors
    user.errors.smarter_full_messages.join(', ') + '.'  
  end

  def user
    @user ||= existing_user || demo.users.new(user_params)
  end

  protected

  def set_phone_number
    if user.phone_number.present?
      user.phone_number = PhoneNumber.normalize(user.phone_number)
    end
  end

  def set_existing_user
    if email.present? 
      User.find_by_email(email)
    end
  end

  def set_role
    if user.demo_id == demo.id
      user.role = role
      user.save!
    end

    new_board_membership = user.board_memberships.where(demo_id: demo.id).first
    new_board_membership.role = role
    new_board_membership.save!
  end

  def is_new_user
    !existing_user.present?
  end

  def ping_if_made_client_admin(user, was_changed)
    if user.is_client_admin && was_changed
      TrackEvent.ping('Creator - New', {source: 'Client Admin'}, current_user)
    end
  end
end
