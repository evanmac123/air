import React from "react";
import PropTypes from "prop-types";

import CampaignComponent from "./CampaignComponent";

const renderCampaigns = (campaigns) =>
  campaigns.map(campaign => React.createElement(CampaignComponent, {...campaign, key: campaign.id}));

const campaignContainerStyle = {
  display: "flex",
  alignItems: "center",
  flexWrap: "wrap",
  justifyContent: "center",
};

const CampaignsComponent = props =>
  React.createElement(
    "div",
    { className: "campaign-container", style: campaignContainerStyle },
    renderCampaigns(props.campaigns),
  );

CampaignsComponent.propTypes = {
  campaigns: PropTypes.array,
};

export default CampaignsComponent;
