class Admin::Reports::ActivitiesController < AdminBaseController
  def create
    Report::Activity.new(params[:demo_id]).delay.send_email(current_user.email)
    flash[:success] = "An Activity Report has been sent. Please check your email in a few minutes."
    redirect_to :back
  end
end
