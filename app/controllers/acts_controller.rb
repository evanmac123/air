class ActsController < ApplicationController
  layout :determine_layout

  def index
    @demo              = current_user.demo
    @demo_user_count   = @demo.users.ranked.count
    @acts              = @demo.acts.recent(10)

    respond_to do |format|
      format.html do 
        @users = @demo.users.ranked.with_ranking_cutoff.order('points DESC')
        @levels = current_user.levels.in_demo(current_user.demo).in_threshold_order
      end

      format.js do
        @acts = @acts.offset(params[:offset])
        render :partial => 'shared/acts', :locals => {:acts => @acts}
      end
    end
  end

  def create
    parsing_message, parsing_message_type = Command.parse(current_user, params[:act][:code], :return_message_type => true)
    flash[parsing_message_type] = parsing_message
    redirect_to :back
  end
end
