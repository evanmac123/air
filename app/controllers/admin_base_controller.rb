class AdminBaseController < UserBaseController
  before_filter :strip_smart_punctuation!
  skip_after_filter :intercom_rails_auto_include

  layout 'admin'

  def authorized?
    return true if current_user.authorized_to?(:site_admin)
    return false
  end

  private

    def find_demo_by_demo_id
      @demo = Demo.find(params[:demo_id])
    end

    def set_admin_page_flag
      @is_admin_page = true
    end

    def parse_start_and_end_dates
      @sdate = params[:sdate].present? ? Date.strptime(params[:sdate], "%Y-%m-%d") : nil
      @edate =  params[:edate].present? ? Date.strptime(params[:edate], "%Y-%m-%d") : nil
    end

    # TODO: Figure out why tese are necessary:

    def strip_smart_punctuation!
      strip_smart_punctuation_from_hash!(params)
    end

    def strip_smart_punctuation_from_hash!(hsh)
      hsh.each do |key, value|
        new_value = case value
                    when String
                      strip_smart_punctuation_from_string(value)
                    when Hash
                      strip_smart_punctuation_from_hash!(value)
                    else
                      value
                    end
        hsh[key] = new_value
      end
    end

    def strip_smart_punctuation_from_string(str)
      str.gsub(/(“|”)/, '"').
          gsub(/(‘|’)/, '\'').
          gsub(/(–|—)/, '-')
    end
end
