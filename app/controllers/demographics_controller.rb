class DemographicsController < ApplicationController
  before_filter :parse_date_of_birth, :only => :update

  def update
    current_user.update_attributes params[:user]
    flash[:success] = "OK, your settings were updated."
    redirect_to :back
  end

  protected

  def parse_date_of_birth
    params[:user][:date_of_birth] = Chronic.parse(params[:user][:date_of_birth], :context => :past)
  end
end
