import React from 'react';
import PropTypes from 'prop-types';

import { DateMaker } from '../../../lib/helpers';

const pluralize = (word, amount) => amount === 1 ? word : `${word}s`;

const calculateTimeLeft = endsAt => {
  const diff = new Date(endsAt).getTime() - new Date();
  const daysLeft = (new Date(diff).getUTCDate() - 1);
  const moreThanAWeek = daysLeft > 7;
  const timeWording = moreThanAWeek ? 'week' : 'day';
  const timeRemaining = Math.ceil(moreThanAWeek ? (daysLeft/7) : daysLeft);
  if (diff > 0) {
    return {
      weeks: moreThanAWeek ? Math.floor(daysLeft/7) : 0,
      days: moreThanAWeek ? daysLeft % 7 : daysLeft,
      complete: `${timeRemaining} ${pluralize(timeWording, timeRemaining)}`,
    };
  }
  return false;
};

const sanitizeEndDate = endsAt => {
  const date = new Date(endsAt);
  return `Ends ${DateMaker.spelledOutMonths[date.getMonth()]} ${date.getDate()}`;
};

const renderPrizes = prizes => prizes.map((prize, key) => (
  React.createElement('div', {key, className: 'prize_row'},
    React.createElement('div', {className: 'prize_icon icon_container'},
      React.createElement('span', {className: 'fa fa-gift'}),
    ),
    React.createElement('div', {className: 'prize_description desc_container'},
      React.createElement('p', {}, prize)
    ),
  )
));

const RaffleProgressBarComponent = props => {
  const { progressBarData } = props;
  const timeLeft = calculateTimeLeft(progressBarData.raffle.ends_at);
  if (timeLeft) {
    return (
      <div className="round_bar" id="raffle_section">
        <div className="progress_header" id="raffle_header">
          Your Entries
        </div>

        <div className="progress_header" id="raffle_data">
          <div id="raffle_time_left">
            <span className="fa fa-clock-o"></span>
            {timeLeft.complete}
          </div>

          <div id="raffle_info">
            <span className="fa fa-trophy"></span>
            Info
          </div>
        </div>

        <div className="progress-radial" data-progress="0">
          <div className="overlay" id="raffle_entries">
            {progressBarData.raffleTickets}
          </div>

          <div className="point_container_ie">
            <div className="point_progress_ie"></div>
          </div>
        </div>

        <div id="prize_modal" className="reveal-modal js-board-prize-modal" data-reveal="" data-raffle-show-start="false" data-raffle-show-finish="false">
          <div className="prize_box">
            <div className="prize_header">
              <h1 className="js-prize-header">Prize</h1>
              <div className="end_date">
                {sanitizeEndDate(progressBarData.raffle.ends_at)}
              </div>
            </div>
            <div className="tickets_row">
              <div className="torhy_icon icon_container">
                <span className="fa fa-trophy"></span>
              </div>
              <div className="raffle_entries desc_container">
                <h1 className="raffle_entries_num prize_num">
                  {progressBarData.raffleTickets}
                </h1>
                <div className="prize_caps">
                  Your entries
                </div>
              </div>
            </div>
            <div className="time_row">
              <div className="clock_icon icon_container">
                <span className="fa fa-clock-o"></span>
              </div>
              <div className="time_left desc_container">
                <div className="time_cell">
                  <h1 className="prize_num" id="first_date_num">
                    {timeLeft.weeks}
                  </h1>
                  <div className="prize_caps" id="first_date_text">
                    {pluralize('week', timeLeft.weeks)}
                  </div>
                </div>
                <div className="time_cell">
                  <h1 className="prize_num" id="second_date_num">
                    {timeLeft.days}
                  </h1>
                  <div className="prize_caps" id="second_date_text">
                    {pluralize('day', timeLeft.days)}
                  </div>
                </div>
              </div>
            </div>
            <div className="prizes_container">
              {renderPrizes(progressBarData.raffle.prizes)}
            </div>
            <div className="ticket_container">
              <div className="ticket_row">
                <div className="prize_icon icon_container">
                  <span className="fa fa-ticket"></span>
                </div>
                <div className="prize_description desc_container">
                  <p style={{fontSize: '14px'}}>
                    You get one entry for every 20 points.
                  </p>
                </div>
              </div>
            </div>
            <div className=" other_info_row">
              {progressBarData.raffle.other_info}
              <div className="button close_modal js-close_prize_modal">
                Start
              </div>
            </div>
          </div>

        </div>
      </div>
    );
  }
  return null;
};

RaffleProgressBarComponent.propTypes = {
  progressBarData: PropTypes.shape({
    raffle: PropTypes.object,
    raffleTickets: PropTypes.number,
  }),
};

export default RaffleProgressBarComponent;
