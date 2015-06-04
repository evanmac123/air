class ClientAdmin::SuggestionsAccessController < ClientAdminBaseController
  before_filter :find_demo

  def update
    @demo.update_attribute :everyone_can_make_tile_suggestions, 
      params[:demo][:everyone_can_make_tile_suggestions]

    unless @demo.everyone_can_make_tile_suggestions
      User.allow_to_make_tile_suggestions params[:allowed_users], @demo
    end

    unless current_user.suggestion_box_prompt_seen
      current_user.suggestion_box_prompt_seen = true
      current_user.save!
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

  def index
    @users = @demo.users_that_allowed_to_suggest_tiles

    render json: { form: form(@demo, @users) }
  end

  protected

  def form(demo, users)
    render_to_string("client_admin/suggestions_access/_form", 
      locals: { demo: demo, users: users }, 
      layout: false
    )
  end

  def find_demo
    @demo = current_user.demo
  end
end
