# frozen_string_literal: true

class PagesController < HighVoltage::PagesController
  before_action :check_auth_status
  layout :layout_for_page

  private

    def layout_for_page
      case page_name
      when "form"
        "form"
      when "demo"
        "demo"
      when "broker"
        "product"
      else
        "marketing_site"
      end
    end

    def page_name
      params[:id] || params[:action]
    end

    def check_auth_status
      if current_user && !current_user.is_guest?
        redirect_to activity_path
      end
    end
end
