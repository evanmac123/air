import React from "react";
import PropTypes from "prop-types";

import CampaignComponent from "./CampaignComponent";

const campaignContainerStyle = {
  display: "flex",
  alignItems: "center",
  flexWrap: "wrap",
  justifyContent: "center",
};

const renderCampaigns = campaigns => (
  campaigns.map(camp => React.createElement(CampaignComponent, {...camp, key: camp.id}))
);

const CampaignsComponent = props => (
  React.createElement(
    "div",
    { className: "campaign-container", style: campaignContainerStyle },
    renderCampaigns(props.campaigns),
  )
);

CampaignsComponent.propTypes = {
  campaigns: PropTypes.array,
};

export default CampaignsComponent;
