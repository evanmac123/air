module PublicBoardHelper
  def guest_user_conversion_modal?(user)
    !user.demo.try(:internal?) && user.demo.try(:guest_user_conversion_modal)
  end
end
