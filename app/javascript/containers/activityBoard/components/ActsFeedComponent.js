import React from 'react';
import PropTypes from 'prop-types';

const ActsFeedComponent = props => {

  return (
    <div className="feeds module js-activity-feed-component" data-page="1" data-per-page="5" data-path="/api/acts" data-missing-avatar-path="https://d2mpftadjvneio.cloudfront.net/assets/avatar_missing-3be7eb0854ce388c13af38cf7a096004.png">
      <h3 id="feeds_title">Activity</h3>
      <ul className="js-user-acts">
        <li className="act">
          <div className="avatar43">
            <img alt="avatar" className="user_avatar avatar_image" />
            <div className="points">
              <span className="point-value small_cap">10 pts</span>
            </div>
          </div>
          <div className="act-details">
            <div className="user">
              User completed a tile
            </div>
            <span className="when small_cap">
              10 minutes ago
            </span>
          </div>
        </li>
      </ul>

      <a href="#" className="button js-see-more-acts see-more-acts" style={{display: 'none'}}>
        <span className="button_text">
          More <i className="fa fa-angle-down" aria-hidden="true"></i>
        </span>
        <i className="fa fa-spinner fa-spin fa-fw" id="see-more-spinner" style={{display: 'none'}} />
      </a>
      <ul>
        <li className="act js-placeholder-act" style={{display: 'none'}}>
          <div className="avatar43">
            <img alt="avatar" className="user_avatar avatar_image" />
          </div>
          <div className="act-details">
            <p className="user small_margin" style={{background:'#e6e6e6', height:'10px'}} />
            <span className="when small_cap" style={{background:'#e6e6e6', height:'10px', width: '50px', display:'block'}} />
          </div>
        </li>
      </ul>
    </div>
  );
};

export default ActsFeedComponent;
