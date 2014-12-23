class ClientAdmin::BoardSettingsController < ClientAdminBaseController
  before_filter :get_board

  def index
  end

  def board_name
    @board.name = params[:demo][:name]
    render json: { success: @board.save }
  end

  def board_logo
    @board.logo = if params[:demo].present? && params[:demo][:logo].present?
                    params[:demo][:logo]
                  else
                    nil # remove custom logo
                  end

    respond_to do |format|
      if @board.save
        format.json { render json: { success: true, logo_url: @board.logo.url } }
        format.html do
          flash[:success] = "Logo is updated"
          redirect_to :back
        end
      else
        format.json { render json: { success: false } }
        format.html do
          flash[:failure] = "Sorry that doesn't look like an image file. Please use a " +
                            "file with the extension .jpg, .jpeg, .gif, .bmp or .png."
          redirect_to :back
        end
      end
    end
  end

  protected

  def get_board
    @board = current_user.demo
  end
end