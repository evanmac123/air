import React from 'react';
import PropTypes from 'prop-types';

const headers = progressBarData => (
  <div className="relative" id="scoreboard_headers">
    <div className="" id="username_header">
      <div className="inline small_cap">Name</div>
    </div>

    {(progressBarData.raffle && progressBarData.raffle.status === 'live') &&
      <div className="active" id="userlevel_header">
        <div className="inline small_cap">Tickets</div>
      </div>
    }
  </div>
);

const friendsList = connections => (
  <tr className="user">
    <td className="user-name">
      <a href="/users/ryanworkman">Ryan Workman</a>
    </td>
  </tr>
);

const ConnectionsComponent = props => (
  <div className="module" id="scoreboard-module">
    <h3>Connections</h3>
    <a className="margin-left-5px link" href="/users">Add</a>
    {
      (props.connections && props.connections.length) ?
        <span>
          {headers(props.progressBarData)}
          <div id="friends_list">
            <table className="scoreboard">
              <tbody>
                {friendsList(props.connections)}
              </tbody>
            </table>
          </div>
        </span>
      :
      <div>No connections yet</div>
    }
  </div>
);

ConnectionsComponent.propTypes = {
  connections: PropTypes.array,
  progressBarData: PropTypes.object,
};

export default ConnectionsComponent;
