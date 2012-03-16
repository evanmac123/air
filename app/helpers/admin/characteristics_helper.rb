module Admin::CharacteristicsHelper
  def form_submit_path
    if @characteristic.new_record?
      if @demo.present?
        admin_demo_characteristics_path(@demo)
      else
        admin_characteristics_path
      end
    else
      admin_characteristic_path(@characteristic)
    end
  end
end
