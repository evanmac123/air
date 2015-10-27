class SupportsController < ApplicationController
  skip_before_filter :authorize
  layout "external"

  def show
  end
end
