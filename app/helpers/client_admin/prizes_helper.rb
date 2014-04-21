module ClientAdmin::PrizesHelper
  def date_in_pick_format date
    if date.present?
      date.strftime("%m/%d/%Y")
    else
      nil
    end
  end
end
