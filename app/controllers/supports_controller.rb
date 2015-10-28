class SupportsController < ApplicationController
  skip_before_filter :authorize
  layout "external"

  def show
    @support = Support.instance
    @content_path = "supports/content"
  end
end
