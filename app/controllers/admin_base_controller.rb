class AdminBaseController < UserBaseController
  skip_after_action :intercom_rails_auto_include

  layout 'admin'

  def authorized?
    signed_in? && current_user.authorized_to?(:site_admin)
  end

  private

    def find_demo_by_demo_id
      @demo = Demo.find(params[:demo_id])
    end
end
