class Admin::SegmentationsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics

    if params[:segment_column].present?# && params[:segment_column].values.any?(&:present?)
      create_segmentation_explanation
      load_segmented_user_information
    end
  end

  protected

  def load_characteristics
    @generic_characteristics = Characteristic.generic
    @demo_specific_characteristics = Characteristic.in_demo(@demo)

    characteristic_allowed_values = {}
    (@generic_characteristics + @demo_specific_characteristics).each do |characteristic|
      characteristic_allowed_values[characteristic.id.to_s] = characteristic.allowed_values
    end
    @characteristic_allowed_value_json = characteristic_allowed_values.to_json.html_safe
  end

  def create_segmentation_explanation
    unless params[:segment_value].present?
      @segmentation_explanation = 'No segmentation, choosing all users'
      return
    end

    @segmentation_explanation = "Segmenting on: "
    prefix = ''

    params[:segment_column].each do |index, characteristic_id|
      characteristic = Characteristic.find(characteristic_id)
      @segmentation_explanation += [prefix, characteristic.name, ' is ' + params[:segment_value][index]].join
      prefix = ', '
    end
  end

  def load_segmented_user_information
    criteria = {}
   
    if params[:segment_value].present?
      params[:segment_column].each do |index, characteristic_id|
        criteria["characteristics.#{characteristic_id}"] = params[:segment_value][index]
      end
      @found_user_ids = User::SegmentationData.where(criteria).map(&:ar_id)
    else
      @found_user_ids = @demo.users.all.map(&:id)
    end

  end
end
