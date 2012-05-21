class Admin::SegmentationsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics

    if params[:segment_column].present?
      @segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], @demo)
    end
  end

  protected

  def load_characteristics
    @dummy_characteristics = DummyCharacteristic.all
    @generic_characteristics = Characteristic.generic
    @demo_specific_characteristics = Characteristic.in_demo(@demo)

    characteristic_input_specifiers = {}
    characteristic_allowed_operators = {}

    (@dummy_characteristics + @generic_characteristics + @demo_specific_characteristics).each do |characteristic|
      characteristic_input_specifiers[characteristic.id.to_s] = characteristic.input_specifier
      characteristic_allowed_operators[characteristic.id.to_s] = characteristic.allowed_operator_names
    end

    @characteristic_input_specifier_json = characteristic_input_specifiers.to_json.html_safe
    @characteristic_allowed_operator_json = characteristic_allowed_operators.to_json.html_safe
  end
end
