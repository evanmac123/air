class ActsController < ApplicationController
  include Reply

  layout "application"

  def index
    @current_link_text = "Home"


    @show_only             = params[:show_only]
    @demo                  = current_user.demo
    @demo_user_count       = @demo.ranked_user_count
    @acts                  = find_requested_acts(@demo)
    @active_act_tab        = active_act_tab
    @active_scoreboard_tag = "All"

    @displayable_task_suggestions = current_user.displayable_task_suggestions
    @displayable_task_suggestions.each {|displayable_task_suggestion| displayable_task_suggestion.display_completion_on_this_request = displayable_task_suggestion.display_completion_on_next_request}
    @displayable_task_suggestions.update_all(:display_completion_on_next_request => false)

    respond_to do |format|
      format.html do 
        @users = find_ranked_users
        @levels = achieved_levels
        @goals = achieved_goals
      end

      format.js do
        render_act_update
      end
    end
  end

  def create
    parsing_message, parsing_message_type = Command.parse(current_user, params[:act][:code], :return_message_type => true, :channel => :web)
    flash[parsing_message_type] = construct_reply(parsing_message)
    flash[:mp_track_activity_box] = ['used activity entry box']
    redirect_to :back
  end

  protected

  def find_requested_acts(demo)
    acts = demo.acts.displayable.recent(10).includes(:user).includes(:rule)

    case @show_only
    when 'following'
      acts.joins("INNER JOIN friendships ON friendships.friend_id = acts.user_id").where(["friendships.user_id = ?", current_user.id])
    when 'mine'
      acts.where(["user_id = ?", current_user.id])
    else
      acts
    end
  end

  def active_act_tab
    case params[:show_only]
    when 'following'
      "Fan Of"
    when 'mine'
      "Mine"
    else
      "All"
    end
  end

  def render_act_update
    @acts = @acts.offset(params[:offset])
    if params[:mode] == 'see-more'
      render :partial => 'shared/more_acts', :locals => {:acts => @acts}
    else
      render :partial => "refiltered_acts", :locals => {:acts => @acts, :active_tab => @active_act_tab}
    end
  end

  def find_ranked_users
    @demo.users.claimed.with_ranking_cutoff.order('points DESC')  
  end

  def achieved_levels
    current_user.levels.in_demo(current_user.demo).in_threshold_order  
  end

  def achieved_goals
    current_user.completed_goals.in_demo(current_user.demo)  
  end

  def self.channel_specific_translations
    {
      :say => "type", 
      :Say => "Type",
      :help_command_explanation => "HELP - help desk, instructions\n"
    }
  end
end
