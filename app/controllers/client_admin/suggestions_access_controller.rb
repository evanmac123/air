class ClientAdmin::SuggestionsAccessController < ClientAdminBaseController
  before_filter :find_demo

  def update
    @demo.update_attribute :everyone_can_make_tile_suggestions, 
      params[:demo][:everyone_can_make_tile_suggestions]

    unless @demo.everyone_can_make_tile_suggestions
      User.allow_to_make_tile_suggestions params[:allowed_users], @demo
    end
    respond_to do |format|
      format.html do
        redirect_to :back
      end

      format.json do
        render json: {success: true}
      end
    end
  end

  protected

  def find_demo
    @demo = current_user.demo
  end
end