import React from 'react';
import PropTypes from 'prop-types';

const ConnectionsComponent = props => {

  return (
    <div className="module" id="scoreboard-module">
      <h3>Connections</h3>
      <a className="margin-left-5px link" href="/users">Add</a>
      <div>No connections yet</div>
    </div>
  );
};

export default ConnectionsComponent;
