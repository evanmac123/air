# frozen_string_literal: true

class SessionsController < Clearance::SessionsController
  before_action :downcase_email

  layout "external"

  def create
    @user = clearance_authenticate(params)

    if @user.nil?
      # flash_failure_after_create
      render json: { not_found: true }
    else
      sign_in(@user, params[:session][:remember_me].to_s == "true")
      if params[:demo_id]
        @user.move_to_new_demo(params[:demo_id])
      end

      flash[:success] = "Welcome back, #{current_user.first_name}!"
      render json: { path: url_after_create }
    end
  end

  def destroy
    IntercomRails::ShutdownHelper::intercom_shutdown_helper(cookies)
    sign_out
    redirect_to(root_path)
  end

  def url_after_create
    return params[:url_after_create] if params[:url_after_create].present?

    if current_user.is_client_admin? || current_user.is_site_admin?
      explore_path
    else
      activity_path
    end
  end

  protected

    def downcase_email
      if params[:session] && params[:session][:email].present?
        params[:session][:email].downcase!
      end
    end

    def flash_failure_after_create
      flash[:failure] = "Sorry, that's an invalid username or password."
    end
end
