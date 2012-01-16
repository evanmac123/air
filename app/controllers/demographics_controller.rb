class DemographicsController < ApplicationController
  before_filter :parse_height, :only => :update
  before_filter :parse_date_of_birth, :only => :update

  def update
    current_user.update_attributes params[:user]
    flash[:success] = "OK, your settings were updated."
    redirect_to :back
  end

  protected

  def parse_height
    height_hash = params[:user][:height]

    # It's OK if neither feet nor inches is set, or if both are set, but not
    # for one to be set without the other.
    
    if height_hash[:feet].empty? && height_hash[:inches].empty?
      params[:user][:height] = ""
      return
    end

    unless height_hash[:feet].present? && height_hash[:inches].present?
      flash[:failure] = "Please make a choice for both feet and inches of height."
      redirect_to :back
    end

    height_in_inches = height_hash[:feet].to_i * 12 + height_hash[:inches].to_i
    params[:user][:height] = height_in_inches
  end

  def parse_date_of_birth
    params[:user][:date_of_birth] = Chronic.parse(params[:user][:date_of_birth], :context => :past)
  end
end
