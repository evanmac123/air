class Api::ClientAdmin::TileEmailReportsController < Api::ClientAdminBaseController

  def index
    reports = TileEmailReportsGenerator.dispatch(
      board: current_user.demo,
      limit: params[:limit],
      page: params[:page]
    )

    render json: {
      data: reports
    }
  end
end
