# FIXME: This service is only used by board_settings, which is pegged for removal
class DeleteUserAccount
  def initialize(user)
    @user = user
  end

  def delete!
    return false unless can_delete?
    @user.destroy
  end

  def error_messages
    @error_messages ||= [].tap do |errors|
      errors << "you can't leave a paid board" if in_a_paid_board?
    end
  end

  private

    def can_delete?
      !in_a_paid_board?
    end

    def in_a_paid_board?
      @in_a_paid_board ||= @user.demos.where(is_paid: true).first.present?
    end
end
