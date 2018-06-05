import React from "react";
import PropTypes from "prop-types";

import CampaignComponent from "./CampaignComponent";

const renderCampaigns = campaigns =>
  campaigns.map(elem =>
    React.createElement(CampaignComponent, {
      ...elem.campaign,
      key: elem.campaign.id,
    })
  );

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
  campaigns: PropTypes.shape({
    private_campaigns: PropTypes.string,
    related_campaigns: PropTypes.string,
  }),
};

export default CampaignsComponent;
