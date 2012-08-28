# encoding: utf-8

class AdminBaseController < ApplicationController
  before_filter :require_site_admin
  before_filter :strip_smart_punctuation!
  before_filter :set_admin_page_flag

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

  def find_demo_by_id
    @demo = Demo.find(params[:id])
  end

  def find_demo_by_demo_id
    @demo = Demo.find(params[:demo_id])
  end

  def load_characteristics(demo)
    @dummy_characteristics, @generic_characteristics, @demo_specific_characteristics = Characteristic.visible_from_demo(demo)
  end

  def attempt_segmentation
    if params[:segment_column].present?
      @segmentation_result = current_user.set_segmentation_results!(params[:segment_column], params[:segment_operator], params[:segment_value], @demo)
    end
  end

  def set_admin_page_flag
    @is_admin_page = true
  end
end
