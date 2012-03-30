class ActsController < ApplicationController
  include Reply

  layout "application"

  def index
    invoke_tutorial
  
    @current_link_text = "Home"
    @current_user = current_user
    
    @show_only             = params[:show_only]
    @demo                  = current_user.demo
    @acts                  = find_requested_acts(@demo)
    @active_act_tab        = active_act_tab

    @displayable_task_suggestions = current_user.displayable_task_suggestions
    @displayable_task_suggestions.each {|displayable_task_suggestion| displayable_task_suggestion.display_completion_on_this_request = displayable_task_suggestion.display_completion_on_next_request}
    @displayable_task_suggestions.update_all(:display_completion_on_next_request => false)
    @displayable_task_suggestions = @displayable_task_suggestions.sort_by &:suggested_task_id
    @num_suggestions_to_display = 3
    respond_to do |format|
      format.html

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

  add_method_tracer :index
  add_method_tracer :create

  protected

  def find_requested_acts(demo)
    acts = demo.acts.displayable_to_user(current_user).recent(10).includes(:rule)

    case @show_only
    when 'following'
      acts.joins("INNER JOIN friendships ON friendships.friend_id = acts.user_id").where(["friendships.user_id = ?", current_user.id])
    when 'mine'
      acts.where(["acts.user_id = ?", current_user.id])
    else
      acts
    end
  end

  def active_act_tab
    case params[:show_only]
    when 'following'
      "Following"
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

  def channel_specific_translations
    {
      :say => "type", 
      :Say => "Type",
      :help_command_explanation => "HELP - help desk, instructions\n"
    }
  end
  

end
