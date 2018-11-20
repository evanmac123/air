import React from "react";
import PropTypes from "prop-types";

import { Fetcher } from '../../lib/helpers';
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
    this.loadTileWall = this.loadTileWall.bind(this);
    this.openTileModal = this.openTileModal.bind(this);
  }

  componentDidMount() {
    this.loadTileWall();
  }

  loadTileWall() {
    Fetcher.xmlHttpRequest({
      method: 'GET',
      path: '/api/v1/tiles?maximum_tiles=16',
      success: resp => {
        this.props.setTiles(resp);
        this.setState({loading: false});
      },
    });
  }

  openTileModal(id) {
    this.props.openFullSizeTile({id, from: 'incomplete'});
  }

  render() {
    return (
      <div className="content">
        <div className="user_container"><ProgressBarComponent /></div>

        <div id="tile_wall" style={this.state.loading ? {paddingBottom: '250px'} : {}}>
          {this.state.loading ?
            <LoadingComponent /> :
            <TileWallComponent
              tiles={this.props.tiles.incomplete}
              tileOrder={this.props.tiles.incomplete.order}
              openTileModal={this.openTileModal}
            />
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
