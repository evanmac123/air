# frozen_string_literal: true

class Api::V1::BoardSettingsController < Api::ApiController
  before_action :verify_origin

  def index
    render json: {
      ribbonTags: current_user.demo.ribbon_tags,
      campaigns: current_user.demo.campaigns
    }
  end

  private
    def verify_origin
      render json: {} unless request.xhr?
    end
end
