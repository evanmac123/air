module Admin::UsersHelper
  def characteristic_select(characteristic, user)
    render 'characteristic_select', :characteristic => characteristic, :user => user
  end

  def characteristic_selects(characteristics, user)
    characteristics.map{|characteristic| characteristic_select(characteristic, user)}.join.html_safe
  end
end
