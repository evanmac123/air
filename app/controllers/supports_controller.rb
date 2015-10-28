class SupportsController < ApplicationController
  skip_before_filter :authorize
  layout "support"

  def show
    @support = Support.instance
    @content_path = "supports/content"
  end
end
