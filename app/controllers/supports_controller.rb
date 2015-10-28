class SupportsController < ApplicationController
  skip_before_filter :authorize
  layout "external"

  def show
    @content_path = "supports/content"
  end
end
