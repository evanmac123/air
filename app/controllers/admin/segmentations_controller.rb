class Admin::SegmentationsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
    load_characteristics(@demo)
    @segmentation_result = current_user.segmentation_results
  end

  def create
    attempt_segmentation
    redirect_to :back
  end
end
