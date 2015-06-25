class MakeSimpleUser
  attr_reader :user_params, :demo, :email, :role, :existing_user

  def initialize user_params, demo
    @user_params = user_params
    @email = user_params[:email]
    @role = user_params[:role]
    @demo = demo
    @existing_user = set_existing_user
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

  def set_existing_user
    if email.present? 
      User.find_by_email(email)
    end
  end

  def set_role
    if is_new_user
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
end
