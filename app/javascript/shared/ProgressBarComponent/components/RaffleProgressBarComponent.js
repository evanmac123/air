import React from 'react';
import PropTypes from 'prop-types';

const calculateTimeLeft = raffle => {
  const diff = new Date(raffle.ends_at).getTime() - new Date();
  const daysLeft = (new Date(diff).getUTCDate() - 1);
  const timeWording = daysLeft > 7 ? 'weeks' : 'days';
  if (diff > 0) {
    return `${Math.ceil(daysLeft > 7 ? (daysLeft/7) : daysLeft)} ${timeWording}`;
  }
  return "Raffle Ended";
};

const RaffleProgressBarComponent = props => (
  <div className="round_bar" id="raffle_section">
    <div className="progress_header" id="raffle_header">
      Your Entries
    </div>

    <div className="progress_header" id="raffle_data">
      <div id="raffle_time_left">
        <span className="fa fa-clock-o"></span>
        {calculateTimeLeft(props.progressBarData.raffle)}
      </div>

      <div id="raffle_info">
        <span className="fa fa-trophy"></span>
        Info
      </div>
    </div>

    <div className="progress-radial" data-progress="0">
      <div className="overlay" id="raffle_entries">
        {props.progressBarData.raffleTickets}
      </div>

      <div className="point_container_ie">
        <div className="point_progress_ie"></div>
      </div>
    </div>
  </div>
);

RaffleProgressBarComponent.propTypes = {
  progressBarData: PropTypes.shape({
    raffle: PropTypes.object,
    raffleTickets: PropTypes.number,
  }),
};

export default RaffleProgressBarComponent;
