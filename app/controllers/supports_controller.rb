class SupportsController < ApplicationController
  layout "support"

  def show
    @support = Support.instance
    @content_path = "supports/content"
  end
end
