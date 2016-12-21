class ActsController < ApplicationController
  include Reply
  include TileBatchHelper

  prepend_before_filter :allow_guest_user, only: :index
  before_filter :use_persistent_message, only: :index

  ACT_BATCH_SIZE = 5

  def index
    current_user.ping_page('activity feed')
    @demo = current_user.demo
    @acts = find_requested_acts(@demo)
    @palette = @demo.custom_color_palette

    set_modals_and_intros

    @displayable_categorized_tiles = Tile.displayable_categorized_to_user(current_user, tile_batch_size)

    decide_if_tiles_can_be_done(@displayable_categorized_tiles[:not_completed_tiles])

    if request.xhr?
      render partial: 'shared/more_acts', locals: { acts: @acts }
    end
  end

  private

    def set_modals_and_intros
      #FIXME this instance var is getting set 3 times
      @display_get_started_lightbox = current_user.display_get_started_lightbox
      @display_get_started_lightbox = false if params[:public_slug].present?

      # This is handy for debugging the lightbox or working on its styles
      @display_get_started_lightbox ||= params[:display_get_started_lightbox]



      if @display_get_started_lightbox
        @get_started_lightbox_message = persistent_message_or_default(current_user)
        current_user.get_started_lightbox_displayed = true
      end

      @display_activity_page_admin_guide = display_admin_guide?

      if @display_activity_page_admin_guide
        current_user.displayed_activity_page_admin_guide = true
      end

      if @display_get_started_lightbox == false
        @display_first_tile_hint =  current_user.intros.display_first_tile_hint?
      end

      current_user.save
    end

    def display_admin_guide?
      current_user.is_client_admin && current_user.displayed_activity_page_admin_guide
    end

    def find_requested_acts(demo)
      offset = params[:offset].present? ? params[:offset].to_i : 0
      acts = Act.displayable_to_user(current_user, demo, ACT_BATCH_SIZE, offset).all
      @show_more_acts_btn = (acts.length == ACT_BATCH_SIZE)
      acts
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

    def find_current_board
      if params[:public_slug]
        @current_board ||= Demo.public_board_by_public_slug(params[:public_slug])
      elsif current_user
        current_user.demo
      end
    end

    def use_persistent_message
      @use_persistent_message = true
    end
end
