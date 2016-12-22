module SegmentationHelper
  def attempt_segmentation(demo)
    if params[:segment_column].present?
      if (params[:segment_column].length > 1 and params[:segment_column].values.include?("")) or
         (params[:segment_value] and params[:segment_value].values.include?(""))
        flash.now[:failure] = "One or more of your characteristic fields is blank."
      else
        @segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], demo)
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render partial: "shared/segmentation_results", locals: {segmentation_results: @segmentation_result}, layout: false }
    end
  end

  def load_characteristics(demo)
    @dummy_characteristics, @generic_characteristics, @demo_specific_characteristics = Characteristic.visible_from_demo(demo)
  end
end
