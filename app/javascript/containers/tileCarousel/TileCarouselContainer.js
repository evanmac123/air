import React from "react";

class TileCarouselContainer extends React.Component {
  constructor(props) {
    super(props);
    this.initiateTileModal = this.initiateTileModal.bind(this);
  }

  componentDidMount() {
    this.setTileData(this.initiateTileModal);
  }

  setTileData(cb) {
    const startTile = {...this.props.ctrl.startTile, fullyLoaded: true};
    const { tileIds, tileType } = this.props.ctrl;
    let tiles = {};
    tiles[tileType] = tileIds.map(id => startTile.id === id ? startTile : { id });
    this.props.setTiles(tiles);
    cb();
  }

  initiateTileModal() {
    const { id } = this.props.ctrl.startTile;
    const { tileType } = this.props.ctrl;
    this.props.openFullSizeTile({
      id,
      from: tileType,
    });
    this.setState({loading: false});
  }

  render() {
    return null;
  }
}

export default TileCarouselContainer;
