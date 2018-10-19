import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { updateTileData } from "../redux/actions";
import { getSanitizedState } from "../redux/selectors";
import { Fetcher } from "../helpers";

class TileStateManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tile: {},
      currentTileIndex: null,
      loading: true,
    };
    this.populateNewTileContentByIndex = this.populateNewTileContentByIndex.bind(this);
  }

  componentDidMount() {
    const { tileOrigin, originId } = this.props;
    this.setCurrentTileIndex(originId, tileOrigin);
    this.renderTileFullTileData(originId);
  }

  fetchFullSizeTileData(id, origin) {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/tiles/${id}`,
      success: resp => {
        this.props.updateTileData({id, origin, resp});
        this.setState({ loading: false });
      },
    });
  }

  renderTileFullTileData(id) {
    const { tiles, tileOrigin } = this.props;
    if (tiles[tileOrigin][id].fullyLoaded) {
      this.setState({ loading: false });
    } else {
      this.setState({ loading: true });
      this.fetchFullSizeTileData(id, tileOrigin);
    }
  }

  calculateRolloverIndex(differenceIndex) {
    const {tiles, tileOrigin} = this.props;
    if (differenceIndex >= tiles[tileOrigin].count) {
      return 0;
    } else if (differenceIndex < 0) {
      return tiles[tileOrigin].count - 1;
    }
    return differenceIndex;
  }

  populateNewTileContentByIndex(indexDifference) {
    const {tiles, tileOrigin} = this.props;
    const newIndex = this.calculateRolloverIndex(this.state.currentTileIndex + indexDifference);
    this.renderTileFullTileData(tiles[tileOrigin].order[newIndex]);
    this.setState({ currentTileIndex: newIndex });
  }

  setCurrentTileIndex(id, tileOrigin) {
    const currentTileIndex = this.props.tiles[tileOrigin].order.indexOf(id);
    this.setState({ currentTileIndex });
  }

  render() {
    const {tiles, tileOrigin} = this.props;
    const currentTileId = tiles[tileOrigin].order[this.state.currentTileIndex];
    const tile = tiles[tileOrigin][currentTileId];
    return (
      <div>
        {
          this.state.loading ?
            <h1> LOADING!!! </h1> :
            <div>
              {this.props.tileOrigin === 'explore' &&
                <h1 onClick={this.props.closeTile}>X</h1>
              }
              <h2>{tile.headline}</h2>
              <ul>
                <li>supportingContent: {tile.supportingContent}</li>
                <li>Points: {tile.points}</li>
              </ul>
              <h3 onClick={() => this.populateNewTileContentByIndex(1)}>Next</h3>
              <h3 onClick={() => this.populateNewTileContentByIndex(-1)}>Prev</h3>
            </div>
        }
      </div>
    );
  }
}

TileStateManager.propTypes = {
  tileOrigin: PropTypes.string,
  originId: PropTypes.string,
  updateTileData: PropTypes.func,
  tiles: PropTypes.shape({
    explore: PropTypes.object,
    edit: PropTypes.object,
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
  closeTile: PropTypes.func,
};

export default connect(
  getSanitizedState,
  { updateTileData }
)(TileStateManager);
