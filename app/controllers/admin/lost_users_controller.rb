# frozen_string_literal: true

class Admin::LostUsersController < AdminBaseController
  def create
    user = find_user_by_search_params
    if user
      msg = "#{user.name} Email: #{user.email}."
      msg += " Overflow email: #{user.overflow_email}." if user.overflow_email.present?
      add_success msg

      redirect_to edit_admin_demo_user_path(user.demo, user)
    else
      add_failure "Could not find user with the email or phone number '#{params[:user][:email]}'"
      redirect_to :back
    end
  end

  private
    def find_user_by_search_params
      search_param = parse_search_params
      if search_param[:type] == "email"
        User.find_by_either_email(params[:user][:email])
      else
        User.find_by(phone_number: search_param[:sanitized])
      end
    end

    def parse_search_params
      if params[:user][:email].include?("@")
        { type: "email" }
      else
        { type: "phone", sanitized: sanitize_phone_number }
      end
    end

    def sanitize_phone_number
      normalized_number = params[:user][:email].gsub(/\D/, "")
      "+1" + normalized_number
    end
end
