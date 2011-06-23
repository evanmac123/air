class Admin::SendActivityDumpsController < ApplicationController
  def create
    Report::Activity.new(params[:demo_id]).email_to('vlad@hengage.com')

    flash[:success] = "Aaaaaaand...sent!"
    redirect_to :back
  end
end
