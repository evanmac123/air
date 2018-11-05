import React from "react";
import PropTypes from "prop-types";

class TileCarouselContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
    };
    this.initiateTileModal = this.initiateTileModal.bind(this);
  }

  componentDidMount() {
    this.setTileData();
  }

  componentDidUpdate() {
    const { startTile, tileType } = this.props.ctrl;
    const statefulTile = this.props.tiles[tileType][startTile.id];
    if (statefulTile && statefulTile.fullyLoaded && this.state.loading) {
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
    this.props.setTiles(tiles);
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

TileCarouselContainer.propTypes = {
  ctrl: PropTypes.shape({
    startTile: PropTypes.object,
    tileType: PropTypes.string,
    tileIds: PropTypes.array,
  }),
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
