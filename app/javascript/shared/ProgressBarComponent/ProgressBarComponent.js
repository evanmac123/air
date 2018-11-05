import React from 'react';
import { connect } from "react-redux";

import { getSanitizedState } from "../../lib/redux/selectors";
import { setProgressBarData } from "../../lib/redux/actions";

function calculateTileProgressWidth(completedTiles, allTiles, fullProgressBar, tileAll, completedTilesBar, fullWidth) {
  const tileAllWidth = tileAll.offsetWidth;
  const minWidth = completedTilesBar.style.width;
  const newWidth = parseInt(fullWidth * completedTiles / allTiles, 10);
  if (completedTiles === 0 && allTiles !== 0) {
    return 0;
  } else if (minWidth > newWidth) {
    return minWidth;
  } else if (allTiles === completedTiles) {
    return fullWidth;
  }
  return newWidth;
}

const loadingProgressBar = () => (
  <div id="user_progress">
    <span className="WHERE_RAFFLE_GOES!!!" style={{display: 'none'}} />
    <div id="total_section">
      <div className="progress_header" id="total_header" />
      <div id="total_points" />
    </div>
    <div id="tile_section">
      <div className="progress_header" id="tile_header" />
      <div id="tile_progress_bar" />
    </div>
  </div>
);

class ProgressBarComponent extends React.Component {
  constructor(props) {
    super(props);
    this.syncProgressBarData = this.syncProgressBarData.bind(this);
    this.renderCompletedTilesBar = this.renderCompletedTilesBar.bind(this);
  }

  componentDidMount() {
    this.syncProgressBarData();
  }

  componentDidUpdate() {
    this.syncProgressBarData();
    this.renderCompletedTilesBar();
  }

  syncProgressBarData() {
    if (this.props.userData.name && !this.props.progressBarData.loaded) {
      const updateData = {
        points: this.props.userData.points || 0,
        raffleTickets: this.props.userData.tickets || 0,
        incompletedTiles: this.props.userData.numOfIncompleteTiles,
        loaded: true,
      };
      this.props.setProgressBarData(updateData);
    }
  }

  renderCompletedTilesBar() {
    const fullProgressBar = document.getElementById("tile_progress_bar");
    const completedTilesBar = document.getElementById("completed_tiles");
    const tileAll = document.getElementById("all_tiles");
    if (!fullProgressBar || !completedTilesBar || !tileAll) { return; } // eslint-disable-line
    const { completedTiles, incompletedTiles } = this.props.progressBarData;
    const fullWidth = incompletedTiles !== completedTiles ? fullProgressBar.offsetWidth - tileAll.offsetWidth : fullProgressBar.offsetWidth;
    const end = calculateTileProgressWidth(completedTiles, incompletedTiles, fullProgressBar, tileAll, completedTilesBar, fullWidth);
    const fillBar = () => {
      const cur = parseInt(completedTilesBar.offsetWidth, 10);
      window.setTimeout(() => {
        if (cur < end) {
          if (end === fullWidth && document.getElementById("all_tiles").style.display !== 'none') {
            document.getElementById("all_tiles").setAttribute("style", "display: none;");
            document.getElementById('complete_info').setAttribute("style", "display: none;");
          }
          completedTilesBar.setAttribute("style", `width: ${cur + 5}px;`);
          fillBar();
        } else if (cur >= end && end === fullWidth) {
          document.getElementById('congrat_header').setAttribute("style", "display: block;");
        }
      }, 10);
    };
    fillBar();
  }

  render() {
    return (
      <div className="user_container">
      {
        !this.props.organization.name || !this.props.progressBarData.loaded ?
          loadingProgressBar() :
          <div id="user_progress">

            <span className="WHERE_RAFFLE_GOES!!!" style={{display: 'none'}} />

            <div id="total_section">
              <div className="progress_header" id="total_header">
                {this.props.organization.pointsWording}
              </div>
              <div id="total_points">
                {this.props.progressBarData.points}
              </div>
            </div>
            <div id="tile_section">
              <div className="progress_header" id="tile_header">
                {this.props.organization.tilesWording}
              </div>
              <div id="tile_progress_bar">

                <div id="all_tiles">
                  {this.props.progressBarData.incompletedTiles}
                </div>

                {(!!this.props.progressBarData.completedTiles ||
                  this.props.progressBarData.incompletedTiles === this.props.progressBarData.completedTiles) &&
                  <div id="completed_tiles">
                    <div id="complete_info">
                      <span className="fa fa-check"></span>
                      <span id="completed_tiles_num">
                        {this.props.progressBarData.completedTiles}
                      </span>
                    </div>
                    <div id="congrat_header">
                      <i className="fa fa-flag-checkered" style={{paddingRight: '10px'}}></i>
                      <div id="congrat_text">
                        {`You've finished all new ${this.props.organization.tilesWording}!`}
                      </div>
                    </div>
                  </div>
                }

              </div>
            </div>
          </div>
      }
      </div>
    );
  }
}

export default connect(
  getSanitizedState,
  { setProgressBarData }
)(ProgressBarComponent);
