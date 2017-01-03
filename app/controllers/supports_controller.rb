class SupportsController < ApplicationController
  layout "support"

  def show
    @support = Support.instance
    @content_path = params[:demo] == "true" ? "supports/demo_content" : "supports/content"
  end
end
