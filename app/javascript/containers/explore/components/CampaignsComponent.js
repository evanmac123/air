import React from "react";
import PropTypes from "prop-types";

import CampaignComponent from "./CampaignComponent";
import SelectedCampaignComponent from "./SelectedCampaignComponent";

const campaignContainerStyleDesktop = {
  display: "flex",
  alignItems: "left",
  flexWrap: "wrap",
  justifyContent: "left",
};

const campaignContainerStyleMobile = {
  display: "inherit",
};

const renderCampaigns = props => (
  props.campaigns.map(campaign => (
    React.createElement(CampaignComponent, {
      ...campaign,
      missingThumbPath: props.user.missingThumbPath,
      winWidth: props.winWidth,
      campaignRedirect: props.campaignRedirect,
      key: campaign.id,
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
        copyAllTiles: props.copyAllTiles,
        copyTile: props.copyTile,
        user: props.user,
        tilePageLoaded: props.tilePageLoaded,
        scrollLoading: props.scrollLoading,
        openTileModal: props.openTileModal,
      },
    )
  :
    React.createElement(
      "div",
      {
        className: "campaign-container",
        style: (props.winWidth > 767 ? campaignContainerStyleDesktop : campaignContainerStyleMobile),
      },
      renderCampaigns(props),
    )
);

CampaignsComponent.propTypes = {
  campaigns: PropTypes.array,
  campaignRedirect: PropTypes.func,
};

export default CampaignsComponent;
