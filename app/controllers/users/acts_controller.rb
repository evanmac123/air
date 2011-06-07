class Users::ActsController < ApplicationController
  def index
    respond_to do |format|
      format.js do
        user = User.find(params[:user_id])
        acts = user.acts.in_demo(user.demo).recent(10).offset(params[:offset])
        render :partial => 'shared/acts', :locals => {:acts => acts, :act_partial_path => 'users/small_act'}
      end
    end
  end
end
