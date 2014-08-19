class UserWithoutBoardSwitching < Draper::Decorator
  decorates :user
  delegate_all

  def can_switch_boards?
    false
  end
end
