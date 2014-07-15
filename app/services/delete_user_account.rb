class DeleteUserAccount
  def initialize(user)
    @user = user
  end

  def delete!
    return false unless can_delete?

    User.transaction do
      lock_password
      schedule_deletion
    end
  end

  def error_messages
    @error_messages ||= [].tap do |errors|
      errors << "you can't leave a paid board" if in_a_paid_board?
    end
  end

  protected

  def can_delete?
    !in_a_paid_board?
  end

  def in_a_paid_board?
    @in_a_paid_board ||= @user.demos.where(is_paid: true).first.present?
  end

  def lock_password
    @user.update_attributes(encrypted_password: "****NO LOGIN****")
  end
  
  def schedule_deletion
    @user.delay.destroy
  end
end
