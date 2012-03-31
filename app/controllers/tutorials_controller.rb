class TutorialsController < ApplicationController

  def create
    # if existing, delete
    existing = current_user.tutorial
    existing.delete if existing
    Tutorial.create(:user_id => current_user.id)
    redirect_to activity_path
  end

  def update
    tutorial = current_user.tutorial
    if params[:tutorial_request] == "no_thanks"
      tutorial.ended_at = Time.now
      tutorial.save
    elsif params[:tutorial_request] == "close"
      tutorial.ended_at = Time.now
      tutorial.save      
    elsif params[:tutorial_request] == "finish"
      tutorial.bump_step
      tutorial.completed = true
      tutorial.ended_at = Time.now
      tutorial.save
    elsif tutorial.present? && ([0,2].include? tutorial.current_step) 
      tutorial.bump_step
    end
    
    redirect_to :back
  end
end
