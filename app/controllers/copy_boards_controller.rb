class CopyBoardsController < ClientAdminBaseController
  # TODO: deprecate
  def create
    render json: {success: false}
  end
end
