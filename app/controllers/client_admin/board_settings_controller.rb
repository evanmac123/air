class ClientAdmin::BoardSettingsController < ClientAdminBaseController
  before_filter :get_board

  def index
  end

  def name
    @board.name = params[:demo][:name]
    render json: { success: @board.save }
  end

  def logo
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

  def email
    @board.email = params[:demo][:email].strip + "@ourairbo.com"
    render json: { success: @board.save }
  end

  def email_name
    @board.custom_reply_email_name = params[:demo][:custom_reply_email_name]
    render json: { success: @board.save }
  end

  def public_link
    @board.public_slug = params[:demo][:public_slug]
    render json: { success: @board.save }
  end

  def welcome_message
    @board.persistent_message = params[:demo][:persistent_message]
    
    render json: { success: @board.save }
  end

  protected

  def get_board
    @board = current_user.demo
  end
end