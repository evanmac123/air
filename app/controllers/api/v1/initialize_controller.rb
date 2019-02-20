# frozen_string_literal: true

class Api::V1::InitializeController < Api::ApiController
  before_action :verify_origin

  def index
    user = current_user
    demo = user.try(:demo)
    render json: {
      user: render_user_data(user) || { name: "guest" },
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
          isClientAdmin: user.is_client_admin?,
          name: user.try(:name),
          id: user.try(:id),
          points: user.try(:points) || 0,
          tickets: user.try(:tickets) || 0,
          email: user.try(:email),
          numOfIncompleteTiles: user.tiles_to_complete_in_demo.count
        }
      end
    end

    def render_demo_data(demo)
      if demo
        {
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
end
