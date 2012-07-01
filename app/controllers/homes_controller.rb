class HomesController < ApplicationController
  before_filter :redirect_to_activity

  private

  def redirect_to_activity
    redirect_to activity_path, :format => :html
  end
end
