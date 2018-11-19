import React from 'react';
import PropTypes from 'prop-types';

const InviteUsersComponent = props => {

  return (
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
  );
};

export default InviteUsersComponent;
