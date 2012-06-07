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
    @dummy_characteristics, @generic_characteristics, @demo_specific_characteristics = Characteristic.visible_from_demo(@demo)
  end
end
