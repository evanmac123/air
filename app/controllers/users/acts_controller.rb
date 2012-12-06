class Users::ActsController < ApplicationController
  def index
    respond_to do |format|
      format.js do
        user = User.find(params[:user_id])
        acts = user.acts.for_profile(current_user, params[:offset])
        render :partial => 'shared/more_acts', :locals => {:acts => acts}
      end
    end
  end
end
