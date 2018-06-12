# frozen_string_literal: true

class Api::V1::CampaignsController < Api::ApiController
  def index
    render json: Campaign.public_private_explore(current_board)
  end
end
