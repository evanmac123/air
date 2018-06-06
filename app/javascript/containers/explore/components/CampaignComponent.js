import React from "react";
import PropTypes from "prop-types";

const CampaignComponent = props => (
  <div className="campaign-card" style={{ width: "18rem" }}>
    <div className="card-body">
      <h5 className="card-title">{props.name}</h5>
      <img src={props.thumbnails[0]} />
    </div>
  </div>
);

CampaignComponent.propTypes = {
  name: PropTypes.string,
  thumbnails: PropTypes.array,
};

export default CampaignComponent;
