# frozen_string_literal: true

class Api::ClientAdmin::CampaignsController < Api::ClientAdminBaseController
  def index
    render json: current_user.demo.campaigns
  end

  def create
    campaign = current_user.demo.campaigns.new(campaign_params)

    if campaign.save
      render json: campaign
    else
      render json: campaign.errors
    end
  end

  def update
    campaign = current_user.demo.campaigns.find(params[:id])

    if campaign.update_attributes(campaign_params)
      render json: campaign
    else
      render json: campaign.errors
    end
  end

  private

    def campaign_params
      params.require(:campaign).permit(:name, :color, :population_segment_id)
    end
end
