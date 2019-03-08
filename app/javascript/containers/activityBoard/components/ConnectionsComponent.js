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

const friendsList = (connections, progressBarData) => connections.map((connection, key) => (
  React.createElement('tr', {key, className: 'user'},
    React.createElement('td', {className: 'user-name'},
      React.createElement('a', {href: `/users/${connection.path}`}, connection.name)
    ),
    React.createElement('td', {className: 'user-name', style: {display: (progressBarData.raffle && progressBarData.raffle.status === 'live') ? '' : 'none'}},
      React.createElement('a', {href: `/users/${connection.path}`}, connection.tickets)
    ),
  )
));

const ConnectionsComponent = props => (
  <div className="module" id="scoreboard-module">
    <h3>Connections</h3>
    <a className="margin-left-5px link" href="/users">Add</a>
    {props.connections &&
      <span>
      {
        props.connections.length ?
        <span>
          {headers(props.progressBarData)}
          <div id="friends_list">
            <table className="scoreboard">
              <tbody>
                {friendsList(props.connections, props.progressBarData)}
              </tbody>
            </table>
          </div>
        </span>
        :
        <div>No connections yet</div>
      }
      </span>
    }
  </div>
);

ConnectionsComponent.propTypes = {
  connections: PropTypes.array,
  progressBarData: PropTypes.object,
};

export default ConnectionsComponent;
