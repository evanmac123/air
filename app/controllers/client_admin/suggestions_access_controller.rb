class ClientAdmin::SuggestionsAccessController < ClientAdminBaseController
  before_filter :find_demo

  def update
    @demo.update_attribute :everyone_can_make_tile_suggestions, 
      params[:demo][:everyone_can_make_tile_suggestions]

    unless @demo.everyone_can_make_tile_suggestions
      # user_ids = params[:allowed_users]
      # users = @demo.users.find(user_ids)
      User.allow_to_make_tile_suggestions params[:allowed_users], @demo
    end

    redirect_to :back
  end

  protected

  def find_demo
    @demo = current_user.demo
  end
end