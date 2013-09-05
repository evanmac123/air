class ActsController < ApplicationController
  include Reply

  skip_before_filter :authorize, only: :index

  def index
    # So we can sign users in when they click on a tile in their digest email
    if params[:tile_token].present?       and
      (user = User.find params[:user_id]) and   # Note that this is an assignment, not an equality test
      EmailLink.validate_token(user, params[:tile_token])
        sign_in(user)
        # Figure it's better to do this so don't have the long tile link that got us here in the browser's address bar
        # e.g. http://localhost:3000/acts?tile_token=3b38f195261a7300a7b617ba654bfe5540f9923c&user_id=666
        # (Better if user does a "Refresh Page" as well)
        flash[:success] = "Welcome back, #{user.name}"
        redirect_to activity_url and return
    else
      # If this fails Clearance does a 'redirect_to' the sign-in page. When run in a 'before_filter' this halts execution
      # and does the redirect. But since we aren't doing the 'authorize' in the context of a 'before_filter' we need
      # to check if Clearance rejected the params ourselves, and, if so, 'return' so its 'redirect' can take place.
      # Note that this will probably never happen, but we have to take into account - and handle - invalid login attempts.
      #authorize
      authenticate_without_game_begun_check
      return if session[:return_to].present?
    end

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
    add_flash!(parsing_message_type, reply)
    flash[:mp_track_activity_box] = ['used activity entry box']

    # Remain on current tile instead of going back to first one if current tile has more rules for them to complete
    unless no_current_tile || on_talking_chicken_example_tile
      remain_on_current_tile_if_rules_left_on_it
    end

    redirect_to :back

    if current_user.tutorial_active?
      set_talking_chicken_sample_tile_done(:keyword)
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
  
  def add_flash!(parsing_message_type, reply)
    case parsing_message_type
    when :success
      add_success reply
    when :failure
      add_failure reply
    else
      flash[parsing_message_type] = reply
    end
  end

  def no_current_tile
    params['current_tile'].blank?
  end

  def on_talking_chicken_example_tile
    params['current_tile'].to_i.zero? # 0 is the default tile for talking chicken
  end

  def remain_on_current_tile_if_rules_left_on_it
    tile = Tile.find params['current_tile']
    session[:start_tile] = params['current_tile'] if tile.has_rules_left_for_user(current_user)
  end
end
