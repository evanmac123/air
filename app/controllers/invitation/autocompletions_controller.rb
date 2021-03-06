class Invitation::AutocompletionsController < UserBaseController
  def index
    text = params[:entered_text].strip.downcase
    demo = current_user.demo
    @matched_users = User.search_for_users text, demo, 5, current_user

    if @matched_users.empty? && demo.is_public?
      @matched_users = search_user_by_email(text, current_user.demo)
    end

    render :layout => false
  end

  protected

  def search_user_by_email email, demo
    return [] if email.is_not_email_address?
    user = demo.users.find_by(email: email)
    user =  User.new(email: email, name: email) unless user
    [user]
  end
end
