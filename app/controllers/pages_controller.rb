class PagesController < HighVoltage::PagesController
  skip_before_filter :authenticate
  before_filter :force_html_format
  layout :determine_layout
end
