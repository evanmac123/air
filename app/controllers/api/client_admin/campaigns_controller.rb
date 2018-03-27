# frozen_string_literal: true

class Api::ClientAdmin::CampaignsController < Api::ClientAdminBaseController
  def create
    campaign = current_user.demo.campaigns.new(campaign_params)

    if campaign.save
      render json: campaign
    else
      render json: campaign.errors
    end
  end

  private

    def campaign_params
      params.require(:campaign).permit(:name, :color)
    end
end
