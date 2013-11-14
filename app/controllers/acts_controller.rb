class ActsController < ApplicationController
  include Reply
  include TileBatchHelper

  skip_before_filter :authorize, only: :index

  ACT_BATCH_SIZE = 5

  def index
    # Initial 'if' statement exists so we can sign users in when they click on a tile in their digest email.
    # There are a lot of comments for such a small group of statements, so pay attention...
    #
    # Regarding the 'true' clause:
    #   Figure it's better to 'redirect' so don't have the long tile link that got us here in the browser's address bar
    #   e.g. http://localhost:3000/acts?tile_token=3b38f195261a7300a7b617ba654bfe5540f9923c&user_id=666
    #   ('http://localhost:3000/acts' is also better - and correct - if the user does a "Refresh Page")
    #
    #   Note that the second 'and' is an assignment (to 'user'), not an equality test
    #
    # Regarding the 'else' clause:
    #   If 'authorize' fails Clearance does a 'redirect_to' the sign-in page. When run in a 'before_filter' this halts
    #   execution and performs the redirect. But since we aren't doing the 'authorize' in the context of a
    #   'before_filter' we need to check if Clearance rejected the log-in params ourselves, and, if so, do a 'return'
    #   so that its 'redirect' can take place.
    #
    #   But wait... it gets even better! We aliased Clearance's 'authorize' to 'authenticate_without_game_begun_check authorize'
    #   in 'application_controller.rb' and in some cases we do a premature 'render' => need to test for that for the same reason.
    #
    #   Bottom Line: We need to avoid a 'double-render error' => See if either Clearance or our code has done a
    #   'render' or 'redirect_to', and if so, get the &^%$# outta here!
    #
    if params[:tile_token].present?         and
       (user = User.find params[:user_id])  and
       EmailLink.validate_token(user, params[:tile_token])
      sign_in(user)
      flash[:success] = "Welcome back, #{user.first_name}"
      redirect_to activity_url and return
    else
      authorize
      return if response_body.present?
    end

    @current_link_text = "Home"
    @current_user = current_user
    
    @current_user.ping_page('activity feed')

    
    @demo                  = current_user.demo
    @acts                  = find_requested_acts(@demo)

    @display_get_started_lightbox = current_user.on_first_login && !(current_user.get_started_lightbox_displayed) && current_user.demo.tiles.active.present?
    if @display_get_started_lightbox
      current_user.get_started_lightbox_displayed = true
      current_user.save
    end

    @displayable_tiles = Tile.displayable_to_user(current_user, tile_batch_size)
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

    current_user.ping('used activity entry box')   
  end

  add_method_tracer :index
  add_method_tracer :create

  protected

  def find_requested_acts(demo)
    demo.acts.displayable_to_user(current_user).recent(ACT_BATCH_SIZE).includes(:rule)
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

