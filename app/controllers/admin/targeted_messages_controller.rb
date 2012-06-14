class Admin::TargetedMessagesController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_segmentation_results

  def show
    load_characteristics(@demo)
  end

  def create
    user_ids = @segmentation_results.found_user_ids
    GenericMailer::BulkSender.delay.bulk_generic_messages(user_ids, params[:subject], '', params[:html_text])
    flash[:success] = "Scheduled messages to #{user_ids.length} users"
    redirect_to :back
  end

  protected

  def find_segmentation_results
    @segmentation_results = current_user.segmentation_results
  end
end
