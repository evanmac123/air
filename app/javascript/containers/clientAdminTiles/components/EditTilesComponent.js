import React from "react";
import PropTypes from "prop-types";

import TileComponent from "../../../shared/TileComponent";

const renderTiles = tiles => (
  tiles.map(tile => (
    React.createElement(TileComponent, {
      key: tile.id,
      date: tile.planDate ? tile.planDate : 'Unplanned',
      caledarIcon: tile.planDate ? 'fa-calendar-check-o' : 'fa-calendar-times-o',
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
          {renderTiles(props.tiles[props.activeStatus])}
        </div>
      </div>
    </div>
  </section>
);

EditTilesComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  tiles: PropTypes.array,
};

export default EditTilesComponent;
