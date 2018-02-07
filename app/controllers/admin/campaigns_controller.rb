# frozen_string_literal: true

class Admin::CampaignsController < AdminBaseController
  def new
    @campaign = Campaign.new
    @demos = Demo.select([:name, :id]).airbo
  end

  def edit
    @campaign = find_campaign
    @demos = Demo.select([:name, :id]).airbo
  end

  def index
    @campaigns = Campaign.order(:name)
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to admin_campaigns_path
    else
      flash.now[:failure] = @campaign.errors.full_messages.join(", ")
      render :new
    end
  end

  def update
    @campaign = find_campaign

    if @campaign.update_attributes(campaign_params)
      redirect_to admin_campaigns_path
    else
      @demos = Demo.select([:name, :id]).airbo
      flash.now[:failure] = @campaign.errors.full_messages.join(", ")
      render :edit
    end
  end

  private
    def campaign_params
      params.require(:campaign).permit(:name, :description, :demo_id, :active, :icon_link, :ongoing)
    end

    def find_campaign
      Campaign.find(params[:id].to_i)
    end
end
