class AdminBaseController < ApplicationController
  before_filter :require_site_admin
  before_filter :strip_smart_punctuation!

  protected

  def require_site_admin
    unless current_user.is_site_admin
      redirect_to '/'
      return false
    end
  end

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
