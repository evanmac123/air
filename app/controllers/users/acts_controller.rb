class Users::ActsController < ApplicationController
  def index
    respond_to do |format|
      format.js do
        user = User.find(params[:user_id])
        acts = user.acts.in_user_demo.displayable_to_user(current_user).recent(10).offset(params[:offset])
        render :partial => 'shared/more_acts', :locals => {:acts => acts}
      end
    end
  end
end
