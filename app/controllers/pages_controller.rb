class PagesController < HighVoltage::PagesController

  layout :layout_for_page

  private

    def layout_for_page
      case page_name
      when 'privacy', 'terms'
        'external'
      when 'home'
        'marketing_site'
      else
        'standalone'
      end
    end

    def page_name
      params[:id] || params[:action]
    end
end
