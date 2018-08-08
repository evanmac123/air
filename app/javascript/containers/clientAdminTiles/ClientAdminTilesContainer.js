import React, { Component } from "react";

import LoadingComponent from "../../shared/LoadingComponent";
// import TileComponent from "../../shared/TileComponent";
import TileStatusNavComponent from "./components/TileStatusNavComponent";
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
  }

  componentDidMount() {
    this.initializeState();
  }

  initializeState() {
    this.setTileStatuses(['Suggested', 'Plan', 'Ready to Send', 'Share', 'Live', 'Archive']);
    Fetcher.xmlHttpRequest({ path: '/api/client_admin/tiles', method: 'GET' }, {
      success: resp => { this.setState({ loading: false, tiles: resp }); },
    });
  }

  setTileStatuses(statuses) {
    this.setState({tileStatusNav: statuses.reduce((result, status) => {
      result.push({ status, tileCount: 0 });
      return result;
    }, [])});
    this.setState({activeStatus: 'Plan'});
  }

  selectStatus(e) {
    const status = e.target.innerText.split(" (")[0];
    this.setState({activeStatus: status});
    AiRouter.navigation(status.toLowerCase(), {
      hashRoute: true,
      appendTo: '/client_admin/tiles',
    });
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
          <h1>Display Goes Here!</h1>
        }
      </div>
    );
  }
}

export default ClientAdminTiles;
