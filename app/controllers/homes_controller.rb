class HomesController < ApplicationController
  def show
    redirect_to activity_path, :format => :html
  end
end
