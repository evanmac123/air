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
  <div className="row">
    {tileTypeDisplay.map(type => renderTilesInOrder(
      props.tiles[type],
      props.tiles[type].order,
      props.openTileModal,
      type,
    ))}
  </div>
);

TileWallComponent.propTypes = {
  tiles: PropTypes.shape({
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
  openTileModal: PropTypes.func,
};

export default TileWallComponent;
