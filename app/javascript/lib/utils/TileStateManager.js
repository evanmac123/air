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
    }
  }

  componentDidMount() {
    const { tileOrigin } = this.props;
    const { id } = this.props.fullSizeTile;
    if (!this.props.tiles[tileOrigin][id].fullyLoaded) { this.fetchFullSizeTileData(id); }
  }

  fetchFullSizeTileData(id) {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/tiles/${id}`,
      success: resp => {
        debugger
      },
    })
  }

  render() {
    return (
      <div>
        {this.props.tileOrigin === 'explore' &&
          <h1 onClick={this.props.closeTile}>X</h1>
        }
        <h2>{this.state.tile.headline}</h2>
      </div>
    );
  }
}

const mapTileStateToProps = state => (
  { tiles: state.tilesData }
)

export default connect(
  getSanitizedState,
  { updateTileData }
)(TileStateManager);
