class ActsController < ApplicationController
  include Reply

  layout "application"

  def index
    invoke_tutorial
  
    @current_link_text = "Home"
    @current_user = current_user
    
    if @current_user.session_count < 3 && session[:invite_friends_modal_shown].nil?
      @div_id = 'invite_friends_facebox'
      @show_greeting = true
      session[:invite_friends_modal_shown] = true
      @current_user.ping_page 'invite friends modal'
    else
      @div_id = 'invite_friends'
      @current_user.ping_page('activity feed') unless @current_user.tutorial_active?
    end

    
    
    @show_only             = params[:show_only]
    @demo                  = current_user.demo
    @acts                  = find_requested_acts(@demo)
    @active_act_tab        = active_act_tab

    @displayable_task_suggestions = current_user.displayable_task_suggestions
    @displayable_task_suggestions.each {|displayable_task_suggestion| displayable_task_suggestion.display_completion_on_this_request = displayable_task_suggestion.display_completion_on_next_request}
    @displayable_task_suggestions.update_all(:display_completion_on_next_request => false)
    @displayable_task_suggestions = @displayable_task_suggestions.sort_by &:task_id
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
    reply = construct_reply(parsing_message)
    case parsing_message_type
    when :success
      add_success reply
    when :failure
      add_failure reply
    else
      flash[parsing_message_type] = reply
    end
    flash[:mp_track_activity_box] = ['used activity entry box']
    redirect_to :back
    if current_user.tutorial_active?
      session[:typed_something_in_playbox] = true if current_user.tutorial.current_step == 1
    else
      current_user.ping('used activity entry box')   
    end
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
      "Friends"
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
      render :partial => "refiltered_acts", :locals => {:acts => @acts, :active_tab => @active_act_tab}, :content_type => "text/html"
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
