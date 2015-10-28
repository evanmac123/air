class SupportsController < ApplicationController
  skip_before_filter :authorize
  layout "support"

  def show
    @support = Support.instance
    @content_path = params[:demo] == "true" ? "supports/demo_content" : "supports/content"
  end
end
