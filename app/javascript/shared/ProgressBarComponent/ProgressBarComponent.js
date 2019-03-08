import React from 'react';
import PropTypes from 'prop-types';
import CountUp from 'react-countup';
import { connect } from "react-redux";

import RaffleProgressBarComponent from "./components/RaffleProgressBarComponent";

import { getSanitizedState } from "../../lib/redux/selectors";
import { setProgressBarData } from "../../lib/redux/actions";

function calculateTileProgressWidth(completedTiles, allTiles, fullProgressBar, tileAll, completedTilesBar, fullWidth) {
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
    window.Airbo.BoardPrizeModal.init();
  }

  componentDidUpdate() {
    this.syncProgressBarData();
    this.renderCompletedTilesBar();
  }

  syncProgressBarData() {
    if (this.props.organization.name && this.props.userData.name && !this.props.progressBarData.loaded) {
      const { points, tickets, numOfIncompleteTiles, ticketThresholdBase } = this.props.userData;
      const startingPoints = points || 0;
      const pointsTowardsTicket = points - ticketThresholdBase;
      const raffleBarCompletion = ((pointsTowardsTicket % 20) / 20) * 100;
      const updateData = {
        startingPoints,
        raffleBarCompletion,
        ticketThresholdBase,
        points: points || 0,
        raffleTickets: tickets || 0,
        incompletedTiles: numOfIncompleteTiles,
        raffle: this.props.organization.raffle,
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
    const { progressBarData, organization } = this.props;
    return (
      <div>
        <div className="user_container">
        {
          !organization.name || !progressBarData.loaded ?
            loadingProgressBar() :
            <div id="user_progress">
              {
                (progressBarData.raffle && progressBarData.raffle.status === 'live') &&
                <RaffleProgressBarComponent
                  {...this.props}
                  percentage={progressBarData.raffleBarCompletion}
                />
              }

              <div id="total_section">
                <div className="progress_header" id="total_header">
                  {organization.pointsWording}
                </div>
                <div id="total_points">
                  <CountUp
                    start={progressBarData.startingPoints}
                    end={progressBarData.points}
                    duration={2.75}
                  />
                </div>
              </div>
              <div id="tile_section">
                <div className="progress_header" id="tile_header">
                  {organization.tilesWording}
                </div>
                <div id="tile_progress_bar">

                  <div id="all_tiles">
                    {progressBarData.incompletedTiles}
                  </div>

                  {(!!progressBarData.completedTiles ||
                    progressBarData.incompletedTiles === progressBarData.completedTiles) &&
                    <div id="completed_tiles">
                      <div id="complete_info">
                        <span className="fa fa-check"></span>
                        <span id="completed_tiles_num">
                          {progressBarData.completedTiles}
                        </span>
                      </div>
                      <div id="congrat_header">
                        <i className="fa fa-flag-checkered" style={{paddingRight: '10px'}}></i>
                        <div id="congrat_text">
                          {`You've finished all new ${organization.tilesWording}!`}
                        </div>
                      </div>
                    </div>
                  }

                </div>
              </div>
            </div>
        }
        </div>


      </div>
    );
  }
}

ProgressBarComponent.propTypes = {
  userData: PropTypes.shape({
    name: PropTypes.string,
    points: PropTypes.number,
    tickets: PropTypes.number,
    ticketThresholdBase: PropTypes.number,
    numOfIncompleteTiles: PropTypes.number,
  }),
  progressBarData: PropTypes.shape({
    loaded: PropTypes.bool,
    completedTiles: PropTypes.number,
    incompletedTiles: PropTypes.number,
    points: PropTypes.number,
    startingPoints: PropTypes.number,
    raffle: PropTypes.object,
  }),
  setProgressBarData: PropTypes.func,
  organization: PropTypes.shape({
    name: PropTypes.string,
    pointsWording: PropTypes.string,
    tilesWording: PropTypes.string,
    raffle: PropTypes.object,
  }),
};


export default connect(
  getSanitizedState,
  { setProgressBarData }
)(ProgressBarComponent);
