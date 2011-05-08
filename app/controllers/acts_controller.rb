class ActsController < ApplicationController
  layout :determine_layout

  def index
    @demo              = current_user.demo
    @demo_user_count   = @demo.users.ranked.count
    # TODO: the next two lines are ugly, wrote them in a big hurry
    @acts              = @demo.acts.order('created_at DESC').limit(10)

    respond_to do |format|
      format.html do 
        @users = @demo.users.ranked.with_ranking_cutoff.order('points DESC')
      end

      format.js do
        @acts = @acts.offset(params[:offset])
      end
    end
  end

  def create
    action_string = if params[:act][:code].present?
                      params[:act][:code]
                    else
                      [params[:act][:key_name], params[:act][:value]].join(' ')
                    end

    parsing_message, parsing_message_type = Act.parse(current_user, action_string, :return_message_type => true)
    flash[parsing_message_type] = parsing_message
    redirect_to :back
  end
end
