class ActsController < ApplicationController
  include Reply

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
    @displayable_tiles = Tile.displayable_to_user_with_sample(current_user)
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

    # Remain on current tile instead of going back to first one if current tile has more rules for them to complete
    unless params['current_tile'].blank? || params['current_tile'].to_i.zero? # 0 is the default tile for talking chicken
      tile = Tile.find params['current_tile']
      session[:start_tile] = params['current_tile'] if (tile.poly? and not tile.all_rule_triggers_satisfied_to_user(current_user))
    end

    redirect_to :back

    if current_user.tutorial_active?
      session[:typed_something_in_playbox] = true if current_user.tutorial.current_step == 2
    else
      current_user.ping('used activity entry box')   
    end
  end

  add_method_tracer :index
  add_method_tracer :create

  protected

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
