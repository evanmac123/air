import React from "react";

import LoadingComponent from "../../shared/LoadingComponent";
import { Fetcher } from "../../lib/helpers";

class TileCarouselContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      tilesFrom: this.props.showCompletedTiles === 'true' ? 'complete' : 'incomplete',
    };
    this.initiateTileModal = this.initiateTileModal.bind(this);
  }

  componentDidMount() {
    this.setTileData(this.initiateTileModal);
  }

  setTileData(cb) {
    const startTile = {...this.props.ctrl.startTile, fullyLoaded: true};
    const { tileIds } = this.props.ctrl;
    let tiles = {};
    tiles[this.state.tilesFrom] = tileIds.map(id => startTile.id === id ? startTile : { id });
    this.props.setTiles(tiles);
    cb();
  }

  initiateTileModal() {
    const { id } = this.props.ctrl.startTile;
    const from = this.state.tilesFrom;
    this.props.openFullSizeTile({
      id,
      from,
    });
    this.setState({loading: false});
  }

  render() {
    return (
      <div>
        {this.state.loading ?
          <LoadingComponent /> :
          <div></div>
        }
      </div>
    )
  }
}

export default TileCarouselContainer;
