import React from 'react';

import CampaignComponent from './CampaignComponent'

const renderCampaigns = campaigns => (
  campaigns.map(elem => React.createElement(CampaignComponent, {...elem.campaign, key: elem.campaign.id}))
)

const CampaignsComponent = props => React.createElement(
  'div',
  { className: 'campaign-container' },
  renderCampaigns(props.campaigns.private_campaigns),
  renderCampaigns(props.campaigns.related_campaigns),
);

export default CampaignsComponent;
