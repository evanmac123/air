class Admin::Reports::ActivitiesController < AdminBaseController
  def create
    Report::Activity.new(params[:demo_id]).delay.email_to('larry@hengage.com')

    flash[:success] = "*****...scheduled! Check for it in a few minutes."
    redirect_to :back
  end
end
