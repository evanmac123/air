import React, { Component } from "react";

import LoadingComponent from "../../shared/LoadingComponent";
import TileStatusNavComponent from "./components/TileStatusNavComponent";
import EditTilesComponent from "./components/EditTilesComponent";
import TileManager from "./utils/TileManager";
import { Fetcher } from "../../lib/helpers";
import { AiRouter } from "../../lib/utils";

const sanitizeTileData = rawTiles => {
  const result = {...rawTiles};
  result.user_submitted = result.user_submitted || [];
  rawTiles.ignored.forEach(tile => {
    result.user_submitted.push({...tile, ignored: true});
  });
  return result;
};

const unhandledClick = e => (e.target.innerText === 'Copy' || e.target.innerText === 'Delete' || e.target.innerText === 'Post' ||
                            (e.target.classList.contains('pill') && e.target.classList.contains('more')));

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
    this.tileContainerClick = this.tileContainerClick.bind(this);
    this.tileDropdownToggle = this.tileDropdownToggle.bind(this);
  }

  componentDidMount() {
    this.selectStatus('plan');
    this.initializeState();
  }

  initializeState() {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/tiles',
      method: 'GET',
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

  setTileStatuses(rawTiles, statuses) {
    const tiles = rawTiles.ignored.length ? sanitizeTileData(rawTiles) : rawTiles;
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
    if (statusNav === 'share') { window.location = '/client_admin/share'; }
    this.setState({activeStatus: statusNav});
    AiRouter.navigation(`tab-${statusNav}`, {
      hashRoute: true,
      appendTo: '/client_admin/tiles',
    });
  }

  changeTileStatus(tile) {
    const statusCycle = {
      user_submitted: 'plan',
      plan: 'draft',
      draft: 'plan',
      active: 'archive',
      archive: 'active',
    };
    const tileManager = new TileManager(tile.id, this);
    tileManager.loading();
    Fetcher.xmlHttpRequest({
      method: 'PUT',
      path: `/api/client_admin/tiles/${tile.id}`,
      params: { new_status: statusCycle[this.state.activeStatus] },
      success: () => {
        tileManager.tileData.selectTile.loading = false;
        tileManager.changeTileStatus(statusCycle[this.state.activeStatus]);
      },
    });
  }

  tileDropdownToggle(tileId, toggle) {
    if (toggle === 'show') {
      document.getElementById(`single-tile-${tileId}`).children[0].classList.add('active_menu');
    } else {
      document.getElementById(`single-tile-${tileId}`).children[0].classList.remove('active_menu');
    }
  }

  tileContainerClick(tile, e) {
    e.preventDefault();
    const targetClass = e.target.classList;
    if (unhandledClick(e)) {
      return; // eslint-disable-line
    } else if (targetClass.contains('update_status')) {
      this.changeTileStatus(tile);
    } else if (e.target.parentElement.classList.contains('edit')) {
      const tileForm = window.Airbo.TileFormModal;
      tileForm.init(window.Airbo.TileManager);
      tileForm.open(tile.editPath);
    } else {
      window.Airbo.TileThumbnail.getPreview(tile.tileShowPath, tile.id);
    }
  }

  render() {
    return (
      <div className="client-admin-tiles-container">
        <TileStatusNavComponent
          tiles={this.state.tiles}
          statuses={this.state.tileStatusNav}
          activeStatus={this.state.activeStatus}
          selectStatus={this.selectStatus}
        />
        {
          this.state.loading ?
          <LoadingComponent /> :
          <EditTilesComponent
            changeTileStatus={this.changeTileStatus}
            tileContainerClick={this.tileContainerClick}
            tileDropdownToggle={this.tileDropdownToggle}
            {...this.state}
          />
        }
      </div>
    );
  }
}

export default ClientAdminTiles;
