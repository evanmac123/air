# frozen_string_literal: true

class Api::V1::InitializeController < Api::ApiController
  before_action :verify_origin

  def index
    user = current_user
    demo = user.try(:demo)
    render json: {
      user: render_user_data(user) || {},
      organization: render_organization_data(demo) || { name: "public_slug" }
    }
  end

  private
    def verify_origin
      render json: {} unless request.xhr?
    end

    def render_user_data(user)
      if user
        {
          isGuestUser: current_user.is_guest?,
          isEndUser: current_user.end_user?,
          isClientAdmin: current_user.is_client_admin?,
          name: current_user.try(:name),
          id: current_user.try(:id),
          points: current_user.try(:points) || 0,
          tickets: current_user.try(:tickets) || 0,
          email: current_user.try(:email)
        }
      end
    end

    def render_organization_data(demo)
      if demo && org = demo.organization
        {
          id: org.id,
          name: org.name,
          tilesWording: org.tiles_wording || "Tiles",
          pointsWording: org.points_wording || "Points"
        }
      end
    end
end
