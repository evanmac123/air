class TutorialsController < ApplicationController

  def update
    tutorial = current_user.tutorial
    if params[:tutorial_request] == "close"
      tutorial.ended_at = Time.now
      tutorial.save
    elsif tutorial.present? && tutorial.current_step == 2
      tutorial.current_step = 3
      tutorial.save
    end
    
    redirect_to :back
  end
end
