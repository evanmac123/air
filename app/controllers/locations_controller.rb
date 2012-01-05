class LocationsController < ApplicationController
  def update
    if params[:user][:location_id].blank?
      current_user.update_attributes(:location_id => "")
      flash[:success] = "You no longer have a location set."
    else
      current_user.update_attributes(:location_id => Location.find(params[:user][:location_id]).id)
      flash[:success] = "OK, your location is now #{current_user.location.name}."
    end
    redirect_to :back
  end
end
