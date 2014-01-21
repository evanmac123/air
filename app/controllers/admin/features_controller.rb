class Admin::FeaturesController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def show
  end

  def update
    if params[:status]
      $rollout.activate_user(:public_board, @demo)
      flash[:success] = "Public board activated"
    else
      $rollout.deactivate_user(:public_board, @demo)
      flash[:success] = "Public board deactivated"
    end

    redirect_to :back
  end
end
