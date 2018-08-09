import React, { Component } from "react";

import LoadingComponent from "../../shared/LoadingComponent";
import TileStatusNavComponent from "./components/TileStatusNavComponent";
import EditTilesComponent from "./components/EditTilesComponent";
import { Fetcher } from "../../lib/helpers";
import { AiRouter } from "../../lib/utils";

class ClientAdminTiles extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeStatus: '',
      tileStatusNav: [],
      loading: true,
    };
    this.initializeState = this.initializeState.bind(this);
    this.setTileStatuses = this.setTileStatuses.bind(this);
    this.selectStatus = this.selectStatus.bind(this);
    this.changeTileStatus = this.changeTileStatus.bind(this);
  }

  componentDidMount() {
    this.selectStatus('plan');
    this.initializeState();
  }

  initializeState() {
    Fetcher.xmlHttpRequest({ path: '/api/client_admin/tiles', method: 'GET' }, {
      success: resp => {
        this.setTileStatuses(resp, {
            user_submitted: 'Suggested',
            plan: 'Plan',
            draft: 'Ready to Send',
            share: 'Share',
            active: 'Live',
            archive: 'Archive',
          });
        },
    });
  }

  setTileStatuses(tiles, statuses) {
    this.setState({
      tileStatusNav: [...Object.keys(statuses)].reverse().reduce((result, status) => {
        const tileCount = tiles[status] ? tiles[status].length : 0;
        const insertStatus = {};
        insertStatus[status] = { tileCount, uiDisplay: statuses[status] };
        return Object.assign(insertStatus , result);
      }, {}),
      loading: false,
      tiles,
    });
  }

  selectStatus(statusNav) {
    this.setState({activeStatus: statusNav});
    AiRouter.navigation(`tab-${statusNav}`, {
      hashRoute: true,
      appendTo: '/client_admin/tiles',
    });
  }

  changeTileStatus(currentStatus) {
    currentStatus;
  }

  render() {
    return (
      <div className="client-admin-tiles-container">
        <TileStatusNavComponent
          statuses={this.state.tileStatusNav}
          activeStatus={this.state.activeStatus}
          selectStatus={this.selectStatus}
        />
        {
          this.state.loading ?
          <LoadingComponent /> :
          <EditTilesComponent
            changeTileStatus={this.changeTileStatus}
            {...this.state}
          />
        }
      </div>
    );
  }
}

export default ClientAdminTiles;
