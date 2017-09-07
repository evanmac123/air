module PublicBoardHelper
  def should_convert_guest_as_user?(user)
    !user.demo.try(:internal?) && user.demo.try(:guest_user_conversion_modal)
  end

  def should_convert_guest_as_prospect?(user)
    user.demo.try(:internal?)
  end
end
