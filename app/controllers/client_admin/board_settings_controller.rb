class ClientAdmin::BoardSettingsController < ClientAdminBaseController
  before_filter :get_board

  def index
  end

  def board_name
    @board.name = params[:demo][:name]
    render json: { success: @board.save }
  end

  def board_logo
    if params[:demo].present?
      @board.logo = params[:demo][:logo].present? ? params[:demo][:logo] : nil   
    end
    
    if @board.save && params[:demo].present?
      render json: { success: true, logo_url: @board.logo.url }
    else
      render json: { success: false }
    end
  end

  protected

  def get_board
    @board = current_user.demo
  end
end