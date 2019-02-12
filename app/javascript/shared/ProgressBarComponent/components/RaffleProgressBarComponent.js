import React from 'react';

const RaffleProgressBarComponent = props => (
  <div className="round_bar" id="raffle_section">
    <div className="progress_header" id="raffle_header">
      Your Entries
    </div>

    <div className="progress_header" id="raffle_data">
      <div id="raffle_time_left">
        <span className="fa fa-clock-o"></span>
        7 weeks
      </div>

      <div id="raffle_info">
        <span className="fa fa-trophy"></span>
        Info
      </div>
    </div>

    <div className="progress-radial" data-progress="0">
      <div className="overlay" id="raffle_entries">
        0
      </div>

      <div className="point_container_ie">
        <div className="point_progress_ie"></div>
      </div>
    </div>
  </div>
);

export default RaffleProgressBarComponent;
