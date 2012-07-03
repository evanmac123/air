class Admin::SegmentationsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics(@demo)
    @segmentation_results = current_user.segmentation_results
  end

  def create
    attempt_segmentation

    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render partial: "shared/segmentation_results", locals: {segmentation_results: @segmentation_result}, layout: false }
    end
  end
end
