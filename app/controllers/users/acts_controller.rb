class Users::ActsController < ApplicationController
  def index
    respond_to do |format|
      format.js do
        user = User.find(params[:user_id])
        acts = user.acts.in_user_demo.recent(10).offset(params[:offset])
        render :partial => 'shared/new_acts', :locals => {:acts => acts}
      end
    end
  end
end
