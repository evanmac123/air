import React from "react";
import PropTypes from "prop-types";

import { MapWithIndex } from "../../../lib/helpers";

const campaignCardStyle = {
  position: "relative",
  width: "12.6rem",
  height: "105px",
  margin: "20px",
};

const thumbnailCascadeStyle = counter => ({
  left: `${counter * 50}px`,
  position: "absolute",
  top: "0px",
  width: "50%",
  boxShadow: "-5px 0px 5px rgba(68, 68, 68, 0.6)",
});

const cardTitleStyle = {
  width: "100%",
  textAlign: "center",
  position: "absolute",
  zIndex: "1000",
  backgroundColor: "rgba(68, 68, 68, 0.6)",
  height: "97%",
  margin: "0",
  paddingTop: "40px",
  color: "white",
};

const renderThumbnails = thumbnails => (
  MapWithIndex(thumbnails, (thumbnail, i) => (
    React.createElement("img", { src: thumbnail, style: thumbnailCascadeStyle(i), key: i })
  ))
);

const CampaignComponent = props => (
  React.createElement(
    "div",
    {
      className: "campaign-card",
      style: campaignCardStyle,
      onClick: () => {
        props.campaignRedirect({
          path: props.path,
          name: props.name,
          id: props.id,
        });
      },
    },
      React.createElement(
        "h3",
        { className: "card-title", style: cardTitleStyle },
        props.name,
      ),
    renderThumbnails(props.thumbnails),
  )
);

CampaignComponent.propTypes = {
  id: PropTypes.number,
  path: PropTypes.string,
  name: PropTypes.string,
  thumbnails: PropTypes.array,
  campaignRedirect: PropTypes.func,
};

export default CampaignComponent;
