class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  private

    def layout_for_page
      case page_name
      when 'demo_link'
        'standalone'
      else
        'marketing_site'
      end
    end

    def page_name
      params[:id] || params[:action]
    end
end
