# frozen_string_literal: true

class Api::V1::InitializeController < Api::ApiController
  before_action :verify_origin

  def index
    user = current_user || find_user_with_params
    demo = user.try(:demo) || find_demo_with_params
    set_modals_and_intros(user) if user
    render json: {
      user: render_user_data(user) || { name: "guest", isGuestUser: true },
      demo: render_demo_data(demo) || {},
      organization: render_organization_data(demo) || { name: "no_org" }
    }
  end

  private
    def render_user_data(user)
      if user
        {
          isGuestUser: user.is_guest?,
          isEndUser: user.end_user?,
          isClientAdmin: user.try(:is_client_admin?) || false,
          name: user.try(:name),
          id: user.try(:id),
          points: user.try(:points) || 0,
          tickets: user.try(:tickets) || 0,
          ticketThresholdBase: user.try(:ticket_threshold_base),
          email: user.try(:email),
          numOfIncompleteTiles: user.tiles_to_complete_in_demo.count,
          path: "/users/#{user.slug}",
          displayBoardWelcomeMessage: @display_board_welcome_message || false
        }
      end
    end

    def render_demo_data(demo)
      if demo
        {
          id: demo.id,
          name: demo.name,
          customWelcomeMessage: demo.custom_welcome_message,
          email: demo.email,
          publicSlug: demo.public_slug,
          isPublic: demo.is_public,
          guestUserConversionModal: demo.guest_user_conversion_modal,
          hideSocial: demo.hide_social
        }
      end
    end

    def render_organization_data(demo)
      if demo && org = demo.organization
        org_data = {
          id: org.id,
          name: org.name,
          tilesWording: org.tiles_wording || "Tiles",
          pointsWording: org.points_wording || "Points"
        }
        demo.raffle ? org_data.merge(JSON.parse(demo.raffle.to_json)) : org_data
      end
    end

    def find_demo_with_params
      if params[:demo_id]
        demo = Demo.find_by(id: params[:demo_id])
        demo && demo.is_public? ? demo : nil
      end
    end

    def set_modals_and_intros(user)
      if user.display_get_started_lightbox || params[:welcome_modal].present?
        @display_board_welcome_message = true
        user.update_attributes(get_started_lightbox_displayed: true)
      end
    end
end
