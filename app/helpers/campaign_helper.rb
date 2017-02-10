module CampaignHelper
  def campaign_formatted_duration(campaign)
    if campaign.duration_description.present?
      campaign.duration_description
    else
      "Recommended duration: #{pluralize(campaign.duration, 'week')}"
    end
  end
end
