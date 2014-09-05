class Admin::TestStatusesController < AdminBaseController
  def update
    new_test_user_status = params[:user][:is_test_user]
    user = User.find_by_slug(params[:user_id])
    user.is_test_user = new_test_user_status
    user.save!

    flash[:success] = if user.is_test_user
                        "OK, this user is now marked as a test user."
                      else
                        "OK, this user is now marked as not a test user."
                      end
    redirect_to :back
  end
end
