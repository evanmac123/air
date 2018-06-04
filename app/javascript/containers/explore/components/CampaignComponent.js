import React from 'react';

const CampaignComponent = campaign => (
  <div className="campaign-card" style={{width: '18rem'}}>
    <div className="card-body">
      <h5 className="card-title">{campaign.name}</h5>
    </div>
  </div>
)

export default CampaignComponent;
