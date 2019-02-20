# frozen_string_literal: true

class PagesController < HighVoltage::PagesController
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
end
