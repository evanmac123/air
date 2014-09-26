class ActsController < ApplicationController
  include Reply
  include TileBatchHelper

  skip_before_filter :authorize, only: :index
  before_filter :allow_guest_user, only: :index

  ACT_BATCH_SIZE = 5

  def index
    return if authorized_by_tile_token # such as if we got here by a digest email

    authorize
    return if response_body.present? # such as if our authorization failed & we're bound for the signin page

    @current_link_text = "Home"
    @current_user = current_user
    
    @current_user.ping_page('activity feed')

    
    @demo                  = current_user.demo
    @acts                  = find_requested_acts(@demo)

    @display_get_started_lightbox = current_user.on_first_login \
                                && !(current_user.get_started_lightbox_displayed) \
                                && current_user.demo.tiles.active.present? \
                                && current_user.show_onboarding?
    if @display_get_started_lightbox
      current_user.get_started_lightbox_displayed = true
      current_user.save
    end
    saw_welcome_pop_up_ping @display_get_started_lightbox

    @display_activity_page_admin_guide = current_user.is_a?(User) \
                                      && current_user.is_client_admin? \
                                      && !current_user.displayed_activity_page_admin_guide? \
                                      && current_user.show_onboarding?
    if @display_activity_page_admin_guide
      current_user.displayed_activity_page_admin_guide = true
      current_user.save!
    end
    
    @displayable_categorized_tiles = Tile.displayable_categorized_to_user(current_user, tile_batch_size)

    show_conversion_form_provided_that { @demo.tiles.active.empty? }
    decide_if_tiles_can_be_done(@displayable_categorized_tiles[:not_completed_tiles])

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

    # Remain on current tile instead of going back to first one if current tile has more rules for them to complete
    unless no_current_tile || on_talking_chicken_example_tile
      remain_on_current_tile_if_rules_left_on_it
    end

    redirect_to :back
  end
  
  add_method_tracer :index
  add_method_tracer :create

  protected

  def find_requested_acts(demo)
    offset = params[:offset].present? ? params[:offset].to_i : 0
    Act.displayable_to_user(current_user, demo, ACT_BATCH_SIZE, offset)
  end

  def render_act_update
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

  def authorized_by_tile_token
    if params[:tile_token].present? && (user = User.find params[:user_id]) && EmailLink.validate_token(user, params[:tile_token])
      sign_in(user)
      if params[:demo_id].present?
        user.move_to_new_demo(params[:demo_id])
      end
      email_clicked_ping(current_user)
      flash[:success] = "Welcome back, #{user.first_name}"
      redirect_to activity_url
    else
      email_clicked_ping(current_user)
      nil # not authorized_by_tile_token
    end
  end

  def find_current_board
    if params[:public_slug]
      Demo.public_board_by_public_slug(params[:public_slug])
    elsif current_user
      current_user.demo
    end
  end

  def saw_welcome_pop_up_ping show_pop_up
    if show_pop_up || current_user.is_a?(PotentialUser)
      source =  if params[:invitation_email_type].present?
                  params[:invitation_email_type]
                elsif params[:public_slug].present?
                  "Public Link"
                end
      ping('Saw welcome pop-up', {source: source}, current_user)
    end
  end
end

