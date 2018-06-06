import React from "react";
import PropTypes from "prop-types";

import { MapWithIndex } from "../../../lib/helpers";

const campaignCardStyle = {
  position: "relative",
  width: "18rem",
  height: "250px",
};

const thumbnailCascadeStyle = counter => ({
  left: `${counter * 50}px`,
  position: "absolute",
  top: "0px",
  width: "50%",
});

const cardTitleStyle = {
  position: "absolute",
  zIndex: "1000",
};

const renderThumbnails = thumbnails => (
  MapWithIndex(thumbnails, (thumbnail, i) => (
    React.createElement("img", { src: thumbnail, style: thumbnailCascadeStyle(i) })
  ))
);

const CampaignComponent = props => (
  React.createElement(
    "div",
    { className: "campaign-card", style: campaignCardStyle },
      React.createElement(
        "h5",
        { className: "card-title", style: cardTitleStyle },
        props.name,
      ),
    renderThumbnails(props.thumbnails),
  )
);

CampaignComponent.propTypes = {
  name: PropTypes.string,
  thumbnails: PropTypes.array,
};

export default CampaignComponent;
