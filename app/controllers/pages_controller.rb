class PagesController < HighVoltage::PagesController
  layout :layout_for_page

  private

    def layout_for_page
      case page_name
      when 'home', 'about',  'terms', 'privacy'
        'marketing_site'
      else
        'standalone'
      end
    end

    def page_name
      params[:id] || params[:action]
    end
end
