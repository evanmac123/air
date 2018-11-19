import React from "react";
import PropTypes from "prop-types";

import LoadingComponent from '../../shared/LoadingComponent';
import ProgressBarComponent from '../../shared/ProgressBarComponent';
import TileWallComponent from './components/TileWallComponent';
import ActsFeedComponent from './components/ActsFeedComponent';
import ConnectionsComponent from './components/ConnectionsComponent';
import InviteUsersComponent from './components/InviteUsersComponent';

class ActivityBoard extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
    };
  }

  componentDidMount() {
    setTimeout(() => {this.setState({loading: false});}, 1000);
  }

  render() {
    return (
      <div className="content">
        <div className="user_container"><ProgressBarComponent /></div>

        <div id="tile_wall" style={this.state.loading ? {paddingBottom: '250px'} : {}}>
          {this.state.loading ?
            <LoadingComponent /> :
            <TileWallComponent />
          }
        </div>

        <div className="row">
          <div className="large-4 columns">
            <ActsFeedComponent />
          </div>

          <div className="large-4 columns">
            <ConnectionsComponent />
          </div>

          <div className="large-4 columns">
            <InviteUsersComponent />
          </div>
        </div>
      </div>
    );
  }
}

export default ActivityBoard;
