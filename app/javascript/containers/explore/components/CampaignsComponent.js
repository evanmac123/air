import React from "react";
import PropTypes from "prop-types";

import CampaignComponent from "./CampaignComponent";

const campaignContainerStyle = {
  display: "flex",
  alignItems: "center",
  flexWrap: "wrap",
  justifyContent: "center",
};

const renderCampaigns = props => (
  props.campaigns.map(campaign => (
    React.createElement(CampaignComponent, {
      id: campaign.id,
      key: campaign.id,
      name: campaign.name,
      path: campaign.path,
      thumbnails: campaign.thumbnails,
      campaignRedirect: props.campaignRedirect,
    }))
  )
);

const CampaignsComponent = props => (
  React.createElement(
    "div",
    { className: "campaign-container", style: campaignContainerStyle },
    renderCampaigns(props),
  )
);

CampaignsComponent.propTypes = {
  campaigns: PropTypes.array,
  campaignRedirect: PropTypes.func,
};

export default CampaignsComponent;
