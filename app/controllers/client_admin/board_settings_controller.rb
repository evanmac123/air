class ClientAdmin::BoardSettingsController < ClientAdminBaseController
  before_filter :get_board

  def index
  end

  def board_name
    @board.name = params[:demo][:name]
    render json: { success: @board.save }
  end

  def board_logo
    @board.logo = params[:demo][:logo] if params[:demo].present?
    @board.save
    redirect_to :back
    #render json: { success: @board.save }
  end

  protected

  def get_board
    @board = current_user.demo
  end
end