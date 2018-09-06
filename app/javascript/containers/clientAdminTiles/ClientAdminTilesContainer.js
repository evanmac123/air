import React, { Component } from "react";
import SweetAlert from 'react-bootstrap-sweetalert';
import { DragDropContext } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';

import LoadingComponent from "../../shared/LoadingComponent";
import CampaignManagerComponent from "../../shared/CampaignManagerComponent";
import TileStatusNavComponent from "./components/TileStatusNavComponent";
import TileFilterSubNavComponent from "./components/TileFilterSubNavComponent";
import EditTilesComponent from "./components/EditTilesComponent";
import { ClientAdminTilesRouter, TileManager, constants } from "./utils";
import { Fetcher, InfiniScroller, Pluck } from "../../lib/helpers";

const sanitizeTileData = rawTiles => {
  const result = {...rawTiles};
  result.user_submitted.tiles = result.user_submitted.tiles || [];
  rawTiles.ignored.tiles.forEach(tile => {
    result.user_submitted.tiles.push({...tile, ignored: true});
  });
  result.user_submitted.count += rawTiles.ignored.count;
  return result;
};

const unhandledClick = e => (e.target.innerText === 'Copy' || e.target.innerText === 'Delete' || e.target.innerText === 'Post' ||
                            (e.target.classList.contains('pill') && e.target.classList.contains('more')));

const addNewTiles = (tileIDs, existingTiles, newTiles) => (
  newTiles.reduce((result, newTile) => {
    if (tileIDs.indexOf(newTile.id) < 0) { result.push(newTile); }
    return result;
  }, existingTiles)
);

const getFilterParams = statusFilter => (
  Object.keys(statusFilter).reduce((result, status) => (
    statusFilter[status] ? `${result}${status}%3D${statusFilter[status].value}%26` : result
  ), '').slice(0, -3)
);

const sanitizeCampaignResponse = camp => (
  {label: camp.name, className: 'campaign-option', value: camp.id, color: camp.color, population: camp.population_segment_id}
);

class ClientAdminTiles extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeStatus: '',
      tileStatusNav: [],
      loading: true,
      scrollLoading: true,
      alert: null,
      appLoaded: false,
      campaigns: [],
      campaignLoading: false,
    };
    this.initializeState = this.initializeState.bind(this);
    this.setTileStatuses = this.setTileStatuses.bind(this);
    this.selectStatus = this.selectStatus.bind(this);
    this.changeTileStatus = this.changeTileStatus.bind(this);
    this.tileContainerClick = this.tileContainerClick.bind(this);
    this.handleMenuAction = this.handleMenuAction.bind(this);
    this.baseAlertOptions = this.baseAlertOptions.bind(this);
    this.getAdditionalTiles = this.getAdditionalTiles.bind(this);
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.loadFilteredTiles = this.loadFilteredTiles.bind(this);
    this.populateCampaigns = this.populateCampaigns.bind(this);
    this.openCampaignManager = this.openCampaignManager.bind(this);
    this.syncCampaignState = this.syncCampaignState.bind(this);
    this.moveTile = this.moveTile.bind(this);
    this.sortTile = this.sortTile.bind(this);
    this.navButtons = [{
      faIcon: 'download',
      text: 'Download Stats',
      classList: 'download-stats-button js-download-stats-button button outlined icon',
      tooltip: 'Download Excel file with statistics for all of the Tiles in this section.',
      statusDisplay: ['active', 'archive'],
    },
    {
      faIcon: 'users',
      text: 'Manage Access',
      classList: 'js-suggestion-box-manage-access button outlined icon',
      statusDisplay: ['user_submitted'],
    },
    {
      faIcon: 'plus',
      text: 'New Tile',
      classList: 'new-tile-button js-new-tile-button button icon',
      statusDisplay: ['user_submitted', 'plan', 'draft', 'active', 'archive'],
    }];

    this.scrollState = new InfiniScroller({
      scrollPercentage: 0.95,
      throttle: 100,
      onScroll: this.getAdditionalTiles,
    });
  }

  componentDidMount() {
    this.selectStatus();
    this.initializeState();
    this.scrollState.setOnScroll();
    window.addEventListener("popstate", this.selectStatus);
    window.Airbo.PubSub.subscribe("tileChangesYO", (event, payload) => {
      try {
        const tile = new TileManager(payload.tileId, this);
        tile.refresh();
      } catch (e) {
        console.log(event)
        // fetch new tile for board
      }
    });
  }

  componentWillUnmount() {
    this.scrollState.removeOnScroll();
    window.addEventListener("popstate", this.selectStatus);
  }

  initializeState() {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/tiles',
      method: 'GET',
      success: resp => {
        this.setTileStatuses(resp, constants.TILE_STATUS);
      },
    });
  }

  populateCampaigns(openAlert) {
    if (this.state.campaigns.length) { return; } // eslint-disable-line
    this.setState({ campaignLoading: true });
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/campaigns',
      method: 'GET',
      success: resp => {
        const campaigns = resp.reduce((result, camp) => result.concat([sanitizeCampaignResponse(camp.campaign)]),
          [constants.UNASSIGNED_CAMPAIGN]);
        if (openAlert) {
          this.setState({
            campaignLoading: false,
            campaigns,
            alert: React.createElement(CampaignManagerComponent, {
              campaigns,
              onClose: this.syncCampaignState,
            }),
          });
        } else {
          this.setState({ campaignLoading: false, campaigns });
        }
      },
    });
  }

  syncCampaignState(newCampaignState) {
    const campaigns = [constants.UNASSIGNED_CAMPAIGN].concat(newCampaignState);
    this.setState({alert: null, campaigns});
  }

  openCampaignManager() {
    if (this.state.campaigns.length) {
      this.setState({
        alert: React.createElement(CampaignManagerComponent, {
          campaigns: this.state.campaigns,
          onClose: this.syncCampaignState,
        }),
      });
    } else {
      this.populateCampaigns(true);
    }
  }

  getAdditionalTiles() {
    if (!this.state.scrollLoading && this.state.tileStatusNav[this.state.activeStatus].page) {
      this.setState({scrollLoading: true});
      const filter = getFilterParams(this.state.tileStatusNav[this.state.activeStatus].filter);
      const page = this.state.tileStatusNav[this.state.activeStatus].page + 1;
      Fetcher.xmlHttpRequest({
        path: `/api/client_admin/tiles?page=${page}&status=${this.state.activeStatus}&filter=${filter}`,
        method: 'GET',
        success: resp => {
          const tileStatusNav = {...this.state.tileStatusNav};
          const tiles = {...this.state.tiles};
          tiles[this.state.activeStatus].tiles = addNewTiles(Pluck(tiles[this.state.activeStatus].tiles, 'id'), tiles[this.state.activeStatus].tiles, resp);
          tileStatusNav[this.state.activeStatus].page = resp.length < 16 ? 0 : tileStatusNav[this.state.activeStatus].page + 1;
          this.setState({
            tileStatusNav,
            tiles,
            scrollLoading: false,
          });
        },
      });
    }
  }

  loadFilteredTiles() {
    const filter = getFilterParams(this.state.tileStatusNav[this.state.activeStatus].filter);
    Fetcher.xmlHttpRequest({
      path: `/api/client_admin/tiles?filter=${filter}&status=${this.state.activeStatus}`,
      method: 'GET',
      success: resp => {
        const tileStatusNav = {...this.state.tileStatusNav};
        const tiles = {...this.state.tiles};
        tiles[this.state.activeStatus].tiles = resp;
        tileStatusNav[this.state.activeStatus].page = resp.length < 16 ? 0 : 1;
        this.setState({
          tileStatusNav,
          tiles,
          loading: false,
        });
      },
    });
  }

  baseAlertOptions() {
    return {
      customClass: 'airbo',
      cancelBtnCssClass: 'cancel',
      confirmBtnCssClass: 'confirm',
      showCancel: true,
      onCancel: () => { this.setState({alert: null }); },
      style: {
        display: 'inherit',
        width: '520px',
      },
    };
  }

  setTileStatuses(rawTiles, statuses) {
    const tiles = rawTiles.ignored.count ? sanitizeTileData(rawTiles) : rawTiles;
    this.setState({
      tileStatusNav: [...Object.keys(statuses)].reverse().reduce((result, status) => {
        const tileCount = tiles[status] ? tiles[status].count : 0;
        const page = tileCount <= 16 ? 0 : 1;
        const filter = {month: null, year: null, campaign: null, sortType: null};
        const insertStatus = {};
        insertStatus[status] = { tileCount, page, filter, uiDisplay: statuses[status] };
        return Object.assign(insertStatus , result);
      }, {}),
      loading: false,
      scrollLoading: false,
      appLoaded: true,
      tiles,
    });
  }

  selectStatus(status) {
    const statuses = Object.keys(constants.TILE_STATUS);
    const activeStatus = statuses.indexOf(status) > -1 ? status : ClientAdminTilesRouter.getRoute();
    this.setState({ activeStatus });
    if (typeof status === 'string') { ClientAdminTilesRouter.to(activeStatus); }
    // The following should be removed as React overhaul replaces old jQuery code
      setTimeout(() => {
        if (activeStatus === 'user_submitted') { window.Airbo.SuggestionBox.init(); }
        if (activeStatus === 'active' || activeStatus === 'archive') { window.Airbo.TileStatsModal.init(); }
        window.Airbo.TileManager.init();
      }, 100);
    // End block that needs to be removed
  }

  changeTileStatus(tile, forceStatus) {
    if (this.state.activeStatus === 'archive' && !forceStatus) {
      this.setState({
        alert: React.createElement(SweetAlert, {
          ...this.baseAlertOptions(),
          title: 'Are you sure about that?',
          confirmBtnText: 'Post Again',
          onConfirm: () => { this.changeTileStatus(tile, 'active'); this.setState({alert: null }); },
        }, 'Users who have completed this Tile already will not see it again. If you want to re-use the content, it may be better to create a copy.'),
      });
    } else {
      const tileManager = new TileManager(tile.id, this);
      const newStatus = forceStatus || constants.STATUS_CYCLE[this.state.activeStatus];
      tileManager.loading();
      Fetcher.xmlHttpRequest({
        method: 'PUT',
        path: `/api/client_admin/tiles/${tile.id}`,
        params: { new_status: newStatus },
        success: () => {
          // Extraneous code used to patch connection between jQuery and React -- Delete when Share is moved to Edit
          if (this.state.activeStatus === 'plan' || this.state.activeStatus === 'draft') {
            const { count } = this.state.tiles.draft;
            const number = newStatus === 'draft' ? count + 1 : count - 1;
            window.Airbo.PubSub.publish("updateShareTabNotification", { number });
          }
          tileManager.changeTileStatus(newStatus, {setLoadingTo: false});
        },
      });
    }
  }

  tileContainerClick(tile, e) {
    e.preventDefault();
    const targetClass = e.target.classList;
    if (unhandledClick(e)) {
      return; // eslint-disable-line
    } else if (e.target.parentElement.classList.contains('delete_tile') || targetClass.contains('delete_tile') || e.target.parentElement.classList.contains('destroy')) {
      this.handleMenuAction(tile, 'delete');
    } else if (targetClass.contains('ignore') || targetClass.contains('undo_ignore')) {
      this.changeTileStatus(tile, (targetClass.contains('ignore') ? 'ignored' : 'user_submitted'));
    } else if (targetClass.contains('update_status')) {
      this.changeTileStatus(tile);
    } else if (e.target.parentElement.classList.contains('edit') || targetClass.contains('edit')) {
      const tileForm = window.Airbo.TileFormModal;
      tileForm.init(window.Airbo.TileManager);
      tileForm.open(tile.editPath);
    } else {
      window.Airbo.TileThumbnail.getPreview(tile.tileShowPath, tile.id);
    }
  }

  handleMenuAction(tile, action) {
    if (action === 'post' || action === 'delete') {
      this.setState({
        alert: React.createElement(SweetAlert, {
          ...this.baseAlertOptions(),
          title: constants.MENU_ALERT_OPTS[action].title,
          onConfirm: () => { constants.MENU_ALERT_OPTS[action].onConfirmAction(tile, this); this.setState({alert: null }); },
        }, constants.MENU_ALERT_OPTS[action].body),
      });
    } else {
      const tileManager = new TileManager(tile.id, this);
      tileManager.loading();
      Fetcher.xmlHttpRequest({
        method: constants.MENU_OPTS[action].method,
        path: `/api/client_admin/tiles/${tile.id}/${constants.MENU_OPTS[action].url}`,
        success: resp => { constants.MENU_OPTS[action].onSuccess(tileManager, resp); },
      });
    }
  }

  handleFilterChange(value, action, target) {
    const changeFilter = (
      (!value || !this.state.tileStatusNav[this.state.activeStatus].filter[target]) ||
      this.state.tileStatusNav[this.state.activeStatus].filter[target].label !== value.label
    );
    if (changeFilter) {
      const newTileStatusNav = {...this.state.tileStatusNav};
      newTileStatusNav[this.state.activeStatus].filter[target] = value;
      this.setState({tileStatusNav: newTileStatusNav, loading: true});
      this.loadFilteredTiles();
    }
  }

  moveTile(dragIndex, hoverIndex) {
    const newTiles = {...this.state.tiles};
    const shiftingTile = newTiles[this.state.activeStatus].tiles.splice(dragIndex, 1)[0];
    newTiles[this.state.activeStatus].tiles.splice(hoverIndex, 0, shiftingTile);
    this.setState({tiles: newTiles});
  }

  sortTile(landingIndex) {
    const { tiles } = this.state.tiles[this.state.activeStatus];
    const { id } = tiles[landingIndex];
    const leftId = landingIndex - 1 >= 0 ? tiles[landingIndex - 1].id : null;
    Fetcher.xmlHttpRequest({
      method: 'POST',
      path: `/api/client_admin/tiles/${id}/sorts`,
      params: {
        sort: {
          left_tile_id: leftId,
        },
      },
      success: () => null,
    });
  }

  render() {
    return (
      <div className="client-admin-tiles-container">
        <TileStatusNavComponent
          tiles={this.state.tiles}
          statuses={this.state.tileStatusNav}
          activeStatus={this.state.activeStatus}
          selectStatus={this.selectStatus}
          navButtons={this.navButtons}
        />
        {
          (this.state.activeStatus !== 'user_submitted' && this.state.activeStatus !== 'draft') &&
          <TileFilterSubNavComponent
            appLoaded={this.state.appLoaded}
            activeStatus={this.state.activeStatus}
            tileStatusNav={this.state.tileStatusNav}
            handleFilterChange={this.handleFilterChange}
            campaigns={this.state.campaigns}
            populateCampaigns={this.populateCampaigns}
            campaignLoading={this.state.campaignLoading}
            openCampaignManager={this.openCampaignManager}
          />
        }
        {
          this.state.loading ?
          <LoadingComponent /> :
          <EditTilesComponent
            changeTileStatus={this.changeTileStatus}
            tileContainerClick={this.tileContainerClick}
            handleMenuAction={this.handleMenuAction}
            moveTile={this.moveTile}
            sortTile={this.sortTile}
            {...this.state}
          />
        }
        {this.state.alert}
        { (this.state.scrollLoading && !this.state.loading) && <LoadingComponent /> }
      </div>
    );
  }
}

export default DragDropContext(HTML5Backend)(ClientAdminTiles);
