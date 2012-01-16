class SettingsController < ApplicationController
  layout "application"

  def edit
    @locations = current_user.demo.locations.alphabetical
  end
end
