class ClientAdmin::SegmentationsController < ClientAdminBaseController
  include SegmentationConcern

  def show
    load_characteristics current_user.demo
  end

  def create
    attempt_segmentation current_user.demo
  end
end
