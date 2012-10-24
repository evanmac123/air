class ActsController < ApplicationController
  include Reply

  before_filter :set_link_target, :only => :index

  def index
    invoke_tutorial
  
    @current_link_text = "Home"
    @current_user = current_user
    
    if @current_user.session_count < 3 && session[:invite_friends_modal_shown].nil?
      @invite_in_modal = true
      session[:invite_friends_modal_shown] = true
      @current_user.ping_page 'invite friends modal'
    else
      @current_user.ping_page('activity feed') unless @current_user.tutorial_active?
    end

    
    
    @demo                  = current_user.demo
    @acts                  = find_requested_acts(@demo)
    @displayable_tiles = current_user.displayable_tiles
    TileCompletion.mark_displayed_one_final_time(@current_user)
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

  def set_link_target
    agent = env['HTTP_USER_AGENT'] 
    if agent && (agent.include? "MSIE 8")
      @link_target = "_self"
    else
      @link_target = "_blank"
    end
  end

  def find_requested_acts(demo)
    demo.acts.displayable_to_user(current_user).recent(10).includes(:rule)
  end

  def render_act_update
    @acts = @acts.offset(params[:offset])
    render :partial => 'shared/more_acts', :locals => {:acts => @acts}
  end

  def channel_specific_translations
    {
      :say => "type", 
      :Say => "Type",
      :help_command_explanation => "HELP - help desk, instructions\n"
    }
  end
  

end
