import React from "react";
import PropTypes from "prop-types";

import TileComponent from "../../../shared/TileComponent";

const sanitizeDate = (status, date) => {
  if (!date) { return status === 'plan' ? 'Unplanned' : null; }
  const splitDate = date.split("T")[0].split("-");
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  if (status === 'plan' || status === 'user_submitted') {
    return `${months[splitDate[1] - 1]} ${splitDate[2]}`;
  }
  return `${splitDate[1]}/${splitDate[2]}/${splitDate[0]}`;
};

const getTileCalInfo = (type, activeStatus, tile) => {
  if (type === 'icon') {
    if (activeStatus === 'active' || activeStatus === 'archive') { return 'fa-calendar'; }
    return tile[`${activeStatus}Date`] ? 'fa-calendar-check-o' : 'fa-calendar-times-o';
  }
  return sanitizeDate(activeStatus, tile[`${activeStatus}Date`]);
};

const renderTiles = (tiles, activeStatus) => (
  tiles.map(tile => (
    React.createElement(TileComponent, {
      key: tile.id,
      date: getTileCalInfo('date', activeStatus, tile),
      caledarIcon: getTileCalInfo('icon', activeStatus, tile),
      ...tile,
    })
  ))
);

const EditTilesComponent = props => (
  <section className="manage_tiles js-ca-tiles-index-module-tab-content">
    <div className="row pt-2">
      <div className="large-12 columns">
        <div id={props.activeStatus}
          className="js-tiles-index-section">
          {renderTiles(props.tiles[props.activeStatus], props.activeStatus)}
        </div>
      </div>
    </div>
  </section>
);

EditTilesComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  tiles: PropTypes.shape({
    user_submitted:PropTypes.array,
    plan:PropTypes.array,
    draft:PropTypes.array,
    share:PropTypes.array,
    active:PropTypes.array,
    archive:PropTypes.array,
  }),
};

export default EditTilesComponent;
