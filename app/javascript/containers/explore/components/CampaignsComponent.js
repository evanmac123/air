import React from "react";
import PropTypes from "prop-types";

import CampaignComponent from "./CampaignComponent";
import SelectedCampaignComponent from "./SelectedCampaignComponent";

const campaignContainerStyle = {
  display: "flex",
  alignItems: "left",
  flexWrap: "wrap",
  justifyContent: "left",
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
      description: campaign.description,
      ongoing: campaign.ongoing,
    }))
  )
);

const CampaignsComponent = props => (
  (Object.keys(props.selectedCampaign).length) ?
    React.createElement(
      SelectedCampaignComponent,
      {
        selectedCampaign: props.selectedCampaign,
        className: "campaign-container",
        tiles: props[`campaignTiles${props.selectedCampaign.id}`],
        navbarRedirect: props.navbarRedirect,
        user: props.user,
      },
    )
  :
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
