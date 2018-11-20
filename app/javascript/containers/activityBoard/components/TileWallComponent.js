import React from 'react';
import PropTypes from 'prop-types';

import TileComponent from "../../../shared/TileComponent";

const TileWallComponent = props => (
  <div className="row">
    {props.tileOrder.map(tileId => React.createElement(
      TileComponent,
      {
        ...props.tiles[tileId],
        thumbnail: props.tiles[tileId].imagePath,
        id: tileId,
        key: tileId,
        tileThumblinkOnClick: () => { props.openTileModal(tileId); },
      })
    )}
  </div>
);

export default TileWallComponent;
