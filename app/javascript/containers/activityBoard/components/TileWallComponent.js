import React from 'react';
import PropTypes from 'prop-types';

import TileComponent from "../../../shared/TileComponent";

const tileTypeDisplay = ["incomplete", "complete"];

const renderTilesInOrder = (tiles, order, openTileModal, type) => order.map(
  tileId => React.createElement(
    TileComponent,
    {
      ...tiles[tileId],
      tileThumbnailClass: type === 'complete' ? 'completed' : 'incomplete',
      thumbnail: tiles[tileId].imagePath,
      id: tileId,
      key: tileId,
      tileThumblinkOnClick: () => { openTileModal(tileId); },
    })
);

const TileWallComponent = props => (
  <div>
    <div className="row">
      {tileTypeDisplay.map(type => renderTilesInOrder(
        props.tiles[type],
        props.tiles[type].order,
        props.openTileModal,
        type,
      ))}
    </div>

    {
      (!props.allTilesDisplayed) &&
      <div id="tile_links">
        <div className="more_tiles_button">
          <a className="show_more_tiles button" onClick={props.loadMoreTiles}>
            <span className="show_more_tiles_copy">
              More <i className="fa fa-angle-down" aria-hidden="true" id="show_more_tiles_down_arrow"></i>
            </span>
            <i className="fa fa-spinner fa-spin fa-fw" id="show_more_tiles_spinner" style={{display: "none"}}></i>
          </a>
        </div>
      </div>
    }
  </div>
);

TileWallComponent.propTypes = {
  tiles: PropTypes.shape({
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
  allTilesDisplayed: PropTypes.bool,
  openTileModal: PropTypes.func,
  loadMoreTiles: PropTypes.func,
};

export default TileWallComponent;
