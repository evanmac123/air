import React from "react";
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
    }
    this.setCurrentTileIndex = this.setCurrentTileIndex.bind(this);
  }

  componentDidMount() {
    const { tileOrigin } = this.props;
    const { id } = this.props.fullSizeTile;
    this.setCurrentTileIndex(id, tileOrigin);
    if (!this.props.tiles[tileOrigin][id].fullyLoaded) {
      console.log("Get tile!")
      this.fetchFullSizeTileData(id, tileOrigin);
    } else {
      console.log("Load from cache")
      this.setState({ loading: false });
    }
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

  populateNewTileContent(indexDifference) {

  }

  setCurrentTileIndex(id, tileOrigin) {
    const currentTileIndex = this.props.tiles[tileOrigin].order.indexOf(id);
    this.setState({ currentTileIndex })
  }

  render() {
    const tile = this.props.tiles[this.props.tileOrigin][this.props.fullSizeTile.id];
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
              <h3 onClick={this.populateNewTileContent(1)}>Next</h3>
              <h3 onClick={this.populateNewTileContent(-1)}>Prev</h3>
            </div>
        }
      </div>
    );
  }
}

export default connect(
  getSanitizedState,
  { updateTileData }
)(TileStateManager);
