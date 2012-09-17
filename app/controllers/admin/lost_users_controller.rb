class Admin::LostUsersController < AdminBaseController
  
  def create 
    email = params[:user][:email]
    user = User.find_by_either_email(email)
    if user
      msg = "#{user.name} Email: #{user.email}."
      msg += " Overflow email: #{user.overflow_email}." if user.overflow_email.present?
      add_success msg
      redirect_to edit_admin_demo_user_path(user.demo, user)
    else
      add_failure "Could not find user with email '#{email}'"
      redirect_to :back
    end
  end
end
