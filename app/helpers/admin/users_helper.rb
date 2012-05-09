module Admin::UsersHelper
  def characteristic_input(characteristic, user)
    render 'characteristic_input', :characteristic => characteristic, :user => user
  end

  def characteristic_inputs(characteristics, user)
    characteristics.map{|characteristic| characteristic_input(characteristic, user)}.join.html_safe
  end
end
