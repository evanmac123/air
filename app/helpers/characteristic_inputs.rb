module CharacteristicInputs
  def characteristic_input(characteristic, user, options={})
    render 'shared/characteristic_input', :characteristic => characteristic, :user => user, :namespace => options[:namespace]
  end

  def characteristic_inputs(characteristics, user)
    characteristics.map{|characteristic| characteristic_input(characteristic, user)}.join.html_safe
  end
end
