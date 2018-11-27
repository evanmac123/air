import React from "react";
import PropTypes from "prop-types";

class TileCarouselContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      startTile: {},
      tileType: '',
    };
    this.initiateTileModal = this.initiateTileModal.bind(this);
  }

  componentDidMount() {
    if (this.props.ctrl && this.props.ctrl.startTile) {
      this.setTileData();
    } else {
      this.loadTilesIntoCarousel();
    }
  }

  componentDidUpdate() {
    const { startTile, tileType, loading } = this.state;
    const statefulTile = this.props.tiles[tileType][startTile.id];
    if (statefulTile && statefulTile.fullyLoaded && loading) {
      this.initiateTileModal();
    } else {
      this.props.redirectTo('/activity');
    }
  }

  setTileData() {
    const startTile = {...this.props.ctrl.startTile, fullyLoaded: true};
    const { tileIds, tileType } = this.props.ctrl;
    const tiles = {};
    tiles[tileType] = tileIds.map(id => startTile.id === id ? startTile : { id }); // eslint-disable-line
    this.setState({ startTile, tileType });
    this.props.setTiles(tiles);
  }

  loadTilesIntoCarousel() {
    const tileId = this.props.routeData.tile_id;
    const { tiles } = this.props;
    const tileTypes = Object.keys(this.props.tiles);
    for (let i = 0; i < tileTypes.length; i++) {
      if (tiles[tileTypes[i]][tileId]) {
        this.setState({
          tileType: tileTypes[i],
          startTile: tiles[tileTypes[i]][tileId],
        });
        break;
      }
    }
  }

  initiateTileModal() {
    const { id } = this.state.startTile;
    const { tileType } = this.state;
    this.props.openFullSizeTile({ id, from: tileType });
    this.setState({loading: false});
  }

  render() {
    return null;
  }
}

TileCarouselContainer.propTypes = {
  ctrl: PropTypes.shape({
    startTile: PropTypes.object,
    tileType: PropTypes.string,
    tileIds: PropTypes.array,
  }),
  routeData: PropTypes.object,
  tiles: PropTypes.shape({
    explore: PropTypes.object,
    edit: PropTypes.object,
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
  setTiles: PropTypes.func,
  openFullSizeTile: PropTypes.func,
  redirectTo: PropTypes.func,
};

export default TileCarouselContainer;
