class ClientAdmin::SuggestionBoxController < ClientAdminBaseController
  def index
    demo = current_user.demo
    users = User.allowed_to_suggest_tiles demo

    render json: { form: form(demo, users) }
  end

  protected

  def form(demo, users)
    render_to_string("client_admin/suggestion_box/_suggestion_box_form", 
      locals: { demo: demo, users: users }, 
      layout: false
    )
  end
end