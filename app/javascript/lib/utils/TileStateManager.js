import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { updateTileData } from "../redux/actions";
import { getSanitizedState } from "../redux/selectors";
import { Fetcher } from "../helpers";
import FullSizeTileComponent from "../../shared/FullSizeTileComponent";

const pingView = id => {
  Fetcher.xmlHttpRequest({
    method: 'POST',
    path: `/api/v1/tiles/${id}/mark_as_viewed`,
    success: () => null,
  });
};

class TileStateManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tile: {},
      currentTileIndex: null,
      loading: true,
    };
    this.populateNewTileContentByIndex = this.populateNewTileContentByIndex.bind(this);
    this.submitAnswer = this.submitAnswer.bind(this);
  }

  componentDidMount() {
    const { tileOrigin, originId } = this.props;
    this.setCurrentTileIndex(originId, tileOrigin);
    this.renderTileFullTileData(originId);
  }

  fetchFullSizeTileData(id, origin, pingTileView) {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/tiles/${id}?ping_tile_view=${pingTileView}`,
      success: resp => {
        this.props.updateTileData({id, origin, resp});
        this.setState({ loading: false });
      },
    });
  }

  renderTileFullTileData(id) {
    const { tiles, tileOrigin } = this.props;
    const pingTileView = tileOrigin === 'complete' || tileOrigin === 'incomplete' ? 'true' : 'false';
    if (!this.state.loading) { this.setState({ loading: true }); }
    if (tiles[tileOrigin][id].fullyLoaded) {
      this.setState({ loading: false });
      if (pingTileView === 'true') { pingView(id); }
    } else {
      this.fetchFullSizeTileData(id, tileOrigin, pingTileView);
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

  submitAnswer(id, answerIndex, freeFormResponse) {
    const origin = this.props.tileOrigin;
    this.setState({ loading: true });
    if (origin === 'explore') {
      this.populateNewTileContentByIndex(1);
    } else {
      Fetcher.xmlHttpRequest({
        method: 'POST',
        path: `/api/tile_completions?tile_id=${id}&answer_index=${answerIndex}&free_form_response=${freeFormResponse}`,
        success: () => {
          this.props.updateTileData({origin, id, resp: {answerIndex, freeFormResponse, complete: true}});
          // this.props.addPointsToProgressBar(id);
          this.populateNewTileContentByIndex(1);
        },
        // err: () => { this.populateNewTileContentByIndex(1); },
      });
    }
  }

  render() {
    const {tiles, tileOrigin} = this.props;
    const currentTileId = tiles[tileOrigin].order[this.state.currentTileIndex];
    const tile = tiles[tileOrigin][currentTileId];
    return (
      <div style={{pointerEvents: `${this.state.loading ? 'none' : ''}`}}>
        <FullSizeTileComponent
          tile={tile}
          organization={this.props.organization}
          loading={this.state.loading}
          nextTile={() => this.populateNewTileContentByIndex(1)}
          prevTile={() => this.populateNewTileContentByIndex(-1)}
          closeTile={this.props.closeTile}
          tileOrigin={this.props.tileOrigin}
          userData={this.props.userData}
          tileActions={this.props.tileActions}
          submitAnswer={this.submitAnswer}
        />
      </div>
    );
  }
}

TileStateManager.propTypes = {
  tileOrigin: PropTypes.string,
  originId: PropTypes.number,
  updateTileData: PropTypes.func,
  tiles: PropTypes.shape({
    explore: PropTypes.object,
    edit: PropTypes.object,
    complete: PropTypes.object,
    incomplete: PropTypes.object,
  }),
  closeTile: PropTypes.func,
  userData: PropTypes.object,
  tileActions: PropTypes.object,
};

export default connect(
  getSanitizedState,
  { updateTileData }
)(TileStateManager);
