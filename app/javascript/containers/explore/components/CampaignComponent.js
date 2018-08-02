import React from "react";
import PropTypes from "prop-types";

import { MapWithIndex } from "../../../lib/helpers";
import { ImgPreload } from "../../../lib/AirUI";

const campaignCardStyleDesktop = {
  position: "relative",
  width: "16.6rem",
  height: "105px",
  margin: "20px",
};

const campaignCardStyleMobile =   {
  position: "relative",
  width: "16.6rem",
  height: "105px",
  margin: "45px auto",
};

const thumbnailCascadeStyle = counter => {
  const baseCss = {
    right: `${counter * 75}px`,
    position: "absolute",
    top: "0px",
    width: "50%",
    borderRadius: "4px",
    marginRight: "-16px",
  };
  if (counter) { baseCss.boxShadow = "5px 0px 5px rgba(68, 68, 68, 0.6)"; }
  return baseCss;
};

const cardTitleStyle = {
  width: "107%",
  textAlign: "center",
  position: "absolute",
  zIndex: "1",
  backgroundColor: "rgba(68, 68, 68, 0.6)",
  height: "128%",
  margin: "0 0 0 -2px",
  padding: "53px 10px 10px 10px",
  color: "white",
  borderRadius: "4px",
  textShadow: "rgb(0, 0, 0) 0px 0px 5px",
};

const renderThumbnails = (thumbnails, missingThumbPath) => (
  MapWithIndex([...thumbnails].reverse(), (thumbnail, i) => (
    React.createElement(ImgPreload, {
      src: thumbnail,
      loadingSrc: missingThumbPath,
      style: thumbnailCascadeStyle(i),
      key: i,
    })
  ))
);

const CampaignComponent = props => (
  React.createElement(
    "div",
    {
      className: "campaign-card",
      style: (props.winWidth > 767 ? campaignCardStyleDesktop : campaignCardStyleMobile),
      onClick: () => {
        props.campaignRedirect(props);
      },
    },
      React.createElement(
        "h3",
        { className: "card-title", style: cardTitleStyle },
        props.name,
      ),
    renderThumbnails(props.thumbnails, props.missingThumbPath),
  )
);

CampaignComponent.propTypes = {
  id: PropTypes.number,
  path: PropTypes.string,
  name: PropTypes.string,
  thumbnails: PropTypes.array,
  campaignRedirect: PropTypes.func,
  description: PropTypes.string,
  ongoing: PropTypes.bool,
  winWidth: PropTypes.number,
  missingThumbPath: PropTypes.string,
};

export default CampaignComponent;
