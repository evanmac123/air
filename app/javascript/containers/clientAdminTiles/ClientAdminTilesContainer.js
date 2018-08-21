import React, { Component } from "react";
import SweetAlert from 'react-bootstrap-sweetalert';

import LoadingComponent from "../../shared/LoadingComponent";
import CampaignManagerComponent from "../../shared/CampaignManagerComponent";
import TileStatusNavComponent from "./components/TileStatusNavComponent";
import TileFilterSubNavComponent from "./components/TileFilterSubNavComponent";
import EditTilesComponent from "./components/EditTilesComponent";
import TileManager from "./utils/TileManager";
import { Fetcher, InfiniScroller, Pluck } from "../../lib/helpers";
import { AiRouter } from "../../lib/utils";

const sanitizeTileData = rawTiles => {
  const result = {...rawTiles};
  result.user_submitted.tiles = result.user_submitted.tiles || [];
  rawTiles.ignored.tiles.forEach(tile => {
    result.user_submitted.tiles.push({...tile, ignored: true});
  });
  return result;
};

const unhandledClick = e => (e.target.innerText === 'Copy' || e.target.innerText === 'Delete' || e.target.innerText === 'Post' ||
                            (e.target.classList.contains('pill') && e.target.classList.contains('more')));

const menuOpts = {
  copy: {
    method: 'POST',
    url: 'copy_tile',
    onSuccess: (tileManager, resp) => { tileManager.addTileToCollection(resp[0], {setLoadingTo: false}); },
  },
  deleteConfirm: {
    method: 'DELETE',
    url: 'destroy_tile',
    onSuccess: tileManager => { tileManager.removeTileFromCollection(); },
  },
};

const menuAlertOpts = {
  post: {
    title: 'Are you sure about that?',
    body: 'Tiles are posted automatically when they are delivered. If you manually post a Tile, it will not appear in your next Tile Digest.',
    onConfirmAction: (tile, component) => { component.changeTileStatus(tile, 'active'); },
  },
  delete: {
    title: 'Deleting a tile cannot be undone',
    body: 'Are you sure you want to delete this tile?',
    onConfirmAction: (tile, component) => { component.handleMenuAction(tile, 'deleteConfirm'); },
  },
};

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
    this.addCampaign = this.addCampaign.bind(this);
    this.populateCampaigns = this.populateCampaigns.bind(this);
    this.openCampaignManager = this.openCampaignManager.bind(this);
    this.handleCampaignChanges = this.handleCampaignChanges.bind(this);
    this.scrollState = new InfiniScroller({
      scrollPercentage: 0.95,
      throttle: 100,
      onScroll: this.getAdditionalTiles,
    });
  }

  componentDidMount() {
    this.selectStatus('plan');
    this.initializeState();
    this.scrollState.setOnScroll();
  }

  componentWillUnmount() {
    this.scrollState.removeOnScroll();
  }

  initializeState() {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/tiles',
      method: 'GET',
      success: resp => {
        this.setTileStatuses(resp, {
          user_submitted: 'Suggested',
          plan: 'Plan',
          draft: 'Proof',
          share: 'Send',
          active: 'Live',
          archive: 'Archive',
        });
      },
    });
  }

  populateCampaigns() {
    if (this.state.campaigns.length) { return; } // eslint-disable-line
    this.setState({ campaignLoading: true });
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/campaigns',
      method: 'GET',
      success: resp => {
        const campaigns = resp.reduce((result, camp) => result.concat([{label: camp.campaign.name, className: 'campaign-option', value: camp.campaign.id}]),
          [{label: 'Unassigned', className: 'campaign-option', value: '0'}]);
        this.setState({ campaignLoading: false, campaigns });
      },
    });
  }

  addCampaign(camp) {
    if (camp && camp.campaign) {
      const newCampaign = [{label: camp.campaign.name, className: 'campaign-option', value: camp.campaign.id}];
      const campaigns = [...this.state.campaigns];
      this.setState({campaigns: campaigns.concat(newCampaign)});
    }
    this.setState({alert: null});
  }

  handleCampaignChanges(action, resp) {
    this.setState({alert: null});
  }

  openCampaignManager() {
    this.setState({
      alert: React.createElement(CampaignManagerComponent, {
        campaigns: this.state.campaigns,
        onClose: this.handleCampaignChanges,
      }),
    });
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

  selectStatus(statusNav) {
    if (statusNav === 'share') { window.location = '/client_admin/share'; }
    this.setState({activeStatus: statusNav});
    AiRouter.navigation(`tab-${statusNav}`, {
      hashRoute: true,
      appendTo: '/client_admin/tiles',
    });
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
      const statusCycle = {
        user_submitted: 'plan',
        plan: 'draft',
        draft: 'plan',
        active: 'archive',
        archive: 'active',
      };
      const tileManager = new TileManager(tile.id, this);
      const newStatus = forceStatus || statusCycle[this.state.activeStatus];
      tileManager.loading();
      Fetcher.xmlHttpRequest({
        method: 'PUT',
        path: `/api/client_admin/tiles/${tile.id}`,
        params: { new_status: newStatus },
        success: () => {
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

  handleMenuAction(tile, action) {
    if (action === 'post' || action === 'delete') {
      this.setState({
        alert: React.createElement(SweetAlert, {
          ...this.baseAlertOptions(),
          title: menuAlertOpts[action].title,
          onConfirm: () => { menuAlertOpts[action].onConfirmAction(tile, this); this.setState({alert: null }); },
        }, menuAlertOpts[action].body),
      });
    } else {
      const tileManager = new TileManager(tile.id, this);
      tileManager.loading();
      Fetcher.xmlHttpRequest({
        method: menuOpts[action].method,
        path: `/api/client_admin/tiles/${tile.id}/${menuOpts[action].url}`,
        success: resp => { menuOpts[action].onSuccess(tileManager, resp); },
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
            {...this.state}
          />
        }
        {this.state.alert}
        { (this.state.scrollLoading && !this.state.loading) && <LoadingComponent /> }
      </div>
    );
  }
}

export default ClientAdminTiles;
