import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";

import { updateTileData, addCompletionAndPointsToProgressBar } from "../redux/actions";
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

const resetPriorSelections = () => {
  const tileQuizSection = document.getElementsByClassName('multiple-choice-answer ');
  if (tileQuizSection.length) {
    for (let i = 0; i < tileQuizSection.length; i++) {
      tileQuizSection[i].className = 'multiple-choice-answer';
      tileQuizSection[i].style.pointerEvents = '';
      if (tileQuizSection[i].nextElementSibling) {
        tileQuizSection[i].nextElementSibling.className = 'answer_target';
      }
    }
  }
};

class TileStateManager extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tile: {},
      currentTileIndex: null,
      loading: true,
      disable: false,
    };
    this.populateNewTileContentByIndex = this.populateNewTileContentByIndex.bind(this);
    this.submitAnswer = this.submitAnswer.bind(this);
    this.trackLinkClick = this.trackLinkClick.bind(this);
  }

  componentDidMount() {
    const { tileOrigin, originId } = this.props;
    this.setCurrentTileIndex(originId, tileOrigin);
    this.renderTileFullTileData(originId);
  }

  fetchFullSizeTileData(id, origin, pingTileView) {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: `/api/v1/tiles/${id}?ping_tile_view=${pingTileView}&include_completion=${origin === 'complete'}`,
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
      resetPriorSelections();
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

  populateNewTileContentByIndex(indexDifference, nextAfterCompletion) {
    if (!this.state.loading || nextAfterCompletion) {
      window.scrollTo(0,0);
      const {tiles, tileOrigin} = this.props;
      const newIndex = this.calculateRolloverIndex(this.state.currentTileIndex + indexDifference);
      this.setState({ loading: true });
      this.renderTileFullTileData(tiles[tileOrigin].order[newIndex]);
      this.setState({ currentTileIndex: newIndex });
    }
  }

  setCurrentTileIndex(id, tileOrigin) {
    const currentTileIndex = this.props.tiles[tileOrigin].order.indexOf(id);
    this.setState({ currentTileIndex });
  }

  submitAnswer(id, answerIndex, freeFormResponse) {
    const origin = this.props.tileOrigin;
    const { points } = this.props.tiles[origin][id];
    this.setState({ disable: true });
    setTimeout(() => {
      this.setState({ loading: true, disable: false });
      if (origin === 'explore') {
        this.populateNewTileContentByIndex(1, true);
      } else {
        Fetcher.xmlHttpRequest({
          method: 'POST',
          path: `/api/tile_completions?tile_id=${id}&answer_index=${answerIndex}&free_form_response=${freeFormResponse}`,
          success: () => {
            this.props.updateTileData({origin, id, resp: {answerIndex, freeFormResponse, complete: true}});
            this.props.addCompletionAndPointsToProgressBar({ points, completion: 1 });
            this.populateNewTileContentByIndex(1, true);
            // Patch sign up modal to communicate with React for every 2nd tile answered
            if (document.getElementById('guest-conversion-modal')) { window.Airbo.PubSub.publish("tileAnswered"); }
          },
          err: () => { this.populateNewTileContentByIndex(1); },
        });
      }
    }, 500);
  }

  trackLinkClick(target, tileId) {
    const clickedLink = target.getAttribute('href');
    if (this.props.tileOrigin !== 'explore') {
      Fetcher.xmlHttpRequest({
        method: 'POST',
        path: `/api/tiles/${tileId}/tile_link_trackings`,
        params: { clicked_link: clickedLink },
        success: () => {},
      });
    }
  }

  render() {
    const {tiles, tileOrigin} = this.props;
    const currentTileId = tiles[tileOrigin].order[this.state.currentTileIndex];
    const tile = tiles[tileOrigin][currentTileId];
    return (
      <div style={{pointerEvents: `${this.state.loading || this.state.disable ? 'none' : ''}`}}>
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
          trackLinkClick={this.trackLinkClick}
        />
      </div>
    );
  }
}

TileStateManager.propTypes = {
  tileOrigin: PropTypes.string,
  originId: PropTypes.number,
  updateTileData: PropTypes.func,
  addCompletionAndPointsToProgressBar: PropTypes.func,
  tiles: PropTypes.shape({
    explore: PropTypes.object,
    edit: PropTypes.object,
    complete: PropTypes.object,
    incomplete: PropTypes.object,
    origin: PropTypes.object,
  }),
  closeTile: PropTypes.func,
  userData: PropTypes.object,
  tileActions: PropTypes.object,
  organization: PropTypes.object,
};

export default connect(
  getSanitizedState,
  { updateTileData, addCompletionAndPointsToProgressBar }
)(TileStateManager);
