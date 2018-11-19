import React from "react";
import PropTypes from "prop-types";

import ProgressBarComponent from '../../shared/ProgressBarComponent';

class ActivityBoard extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="content">
        <div className="user_container"><ProgressBarComponent /></div>

        <div id="tile_wall"><h1>TILES!</h1></div>

        <div className="row">
          <div className="large-4 columns">
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
          </div>

          <div className="large-4 columns">
            <div className="module" id="scoreboard-module">
              <h3>Connections</h3>
              <a className="margin-left-5px link" href="/users">Add</a>
              <div>No connections yet</div>
            </div>
          </div>

          <div className="large-4 columns">
            <div className="module" id="invite-module">
              <div className="invite" id="invite_friends">
                <div id="search_for_friends_to_invite">
                  <div id="invite_friends_top">
                    <h3 id="invite_your_friends_title">Invite</h3>
                    <p id="why_invite">Earn 5 points for each one that joins and gives you credit for recruiting them.</p>
                    <div id="points_per_referral" />
                  </div>
                  <div id="invite_friends_middle">
                    <ul className="form-section">
                      <li className="form-label">
                        <label>Who do you want to invite?</label>
                      </li>
                      <li className="form-input">
                        <input type="text" name="autocomplete" id="autocomplete" placeholder="Type Name or Email" />
                      </li>
                    </ul>
                    <div className="small_cap" id="autocomplete_status" style={{width: '99%'}} />
                    <div id="potential_bonus_points" style={{display: 'none'}}>0</div>
                  </div>
                  <div id="invite_friends_bottom">
                    <div id="suggestions">
                      <div className="clear" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default ActivityBoard;
