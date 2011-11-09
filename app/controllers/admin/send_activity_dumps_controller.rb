class Admin::SendActivityDumpsController < ApplicationController
  def create
    Report::Activity.new(params[:demo_id]).delay.email_to('vlad@hengage.com')

    flash[:success] = "Aaaaaaand...scheduled! Check for it in a few minutes."
    redirect_to :back
  end
end
