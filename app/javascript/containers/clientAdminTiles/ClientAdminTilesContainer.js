import React, { Component } from "react";
import { DragDropContext } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';

import LoadingComponent from "../../shared/LoadingComponent";
import TileStatusNavComponent from "./components/TileStatusNavComponent";
import TileFilterSubNavComponent from "./components/TileFilterSubNavComponent";
import EditTilesComponent from "./components/EditTilesComponent";
import { ClientAdminTilesRouter, TileManager, constants, helpers } from "./utils";
import { Fetcher, InfiniScroller, Pluck } from "../../lib/helpers";

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
    this.setTileStatuses = this.setTileStatuses.bind(this);
    this.selectStatus = this.selectStatus.bind(this);
    this.changeTileStatus = this.changeTileStatus.bind(this);
    this.tileContainerClick = this.tileContainerClick.bind(this);
    this.handleMenuAction = this.handleMenuAction.bind(this);
    this.triggerModal = this.triggerModal.bind(this);
    this.getAdditionalTiles = this.getAdditionalTiles.bind(this);
    this.handleFilterChange = this.handleFilterChange.bind(this);
    this.populateCampaigns = this.populateCampaigns.bind(this);
    this.openCampaignManager = this.openCampaignManager.bind(this);
    this.syncCampaignState = this.syncCampaignState.bind(this);
    this.moveTile = this.moveTile.bind(this);
    this.sortTile = this.sortTile.bind(this);
    this.tileBuilderPatch = this.tileBuilderPatch.bind(this);

    this.scrollState = new InfiniScroller({
      scrollPercentage: 0.95,
      throttle: 100,
      onScroll: () => { this.getAdditionalTiles({scrollLoading: true}); },
    });
  }

  componentDidMount() {
    this.selectStatus();
    TileManager.fetchAllTiles(this.setTileStatuses);
    this.scrollState.setOnScroll();
    window.addEventListener("popstate", this.selectStatus);
    window.Airbo.PubSub.subscribe("reactTileChangeHandler", this.tileBuilderPatch);
    window.Airbo.PubSub.subscribe("/tile-admin/tile-deleted", (e, payload) => {
      this.tileBuilderPatch(e, {tileId: payload.tile.selector.split('=')[1].slice(0, -1)});
    });
  }

  componentWillUnmount() {
    this.scrollState.removeOnScroll();
    window.Airbo.PubSub.unsubscribe("reactTileChangeHandler");
    window.Airbo.PubSub.unsubscribe("/tile-admin/tile-deleted");
    window.addEventListener("popstate", this.selectStatus);
  }

  populateCampaigns(openAlert) {
    if (this.state.campaigns.length) { return; } // eslint-disable-line
    this.setState({ campaignLoading: true });
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/campaigns',
      method: 'GET',
      success: resp => {
        const campaigns = resp.reduce((result, camp) => result.concat([helpers.sanitizeCampaignResponse(camp.campaign)]),
          [constants.UNASSIGNED_CAMPAIGN]);
        if (openAlert) {
          this.setState({
            campaignLoading: false,
            campaigns,
            alert: helpers.campaignManager(campaigns, this.syncCampaignState),
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
      this.setState({ alert: helpers.campaignManager(this.state.campaigns, this.syncCampaignState) });
    } else {
      this.populateCampaigns(true);
    }
  }

  getAdditionalTiles(loadingState, statusFilter) {
    const filter = helpers.getFilterParams(this.state.tileStatusNav[this.state.activeStatus].filter);
    const page = statusFilter ? 1 : this.state.tileStatusNav[this.state.activeStatus].page + 1;
    const status = this.state.activeStatus;
    if (statusFilter || (!this.state.scrollLoading && page - 1)) {
      this.setState(loadingState);
      TileManager.fetchTilesWithParams({filter, page, status}, resp => {
        const tileStatusNav = {...this.state.tileStatusNav};
        const tiles = {...this.state.tiles};
        const nextPage = statusFilter ? 1 : page;
        const purgedTiles = helpers.purgeRepeatedTiles(Pluck(tiles[status].tiles, 'id'), tiles[status].tiles, resp);
        tiles[status].tiles = statusFilter ? resp : purgedTiles;
        tileStatusNav[status].page = resp.length < 16 ? 0 : nextPage;
        this.setState({tileStatusNav, tiles, loading: false, scrollLoading: false});
      });
    }
  }

  setTileStatuses(rawTiles, statuses) {
    const tiles = rawTiles.ignored.count ? helpers.sanitizeTileData(rawTiles) : rawTiles;
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

  triggerModal(args) {
    const alert = helpers.swalModal({...args, onCancel: () => { this.setState({alert: null }); }});
    this.setState({ alert });
  }

  changeTileStatus(tile, forceStatus) {
    if (this.state.activeStatus === 'archive' && !forceStatus) {
      this.triggerModal({
        ...constants.POST_AGAIN_MODAL_TEXT,
        onConfirm: () => { this.changeTileStatus(tile, 'active'); this.setState({alert: null }); },
      });
    } else {
      const tileManager = new TileManager(tile.id, this);
      const newStatus = forceStatus || constants.STATUS_CYCLE[this.state.activeStatus];
      const { count } = this.state.tiles.draft; // Extraneous code used to patch connection between jQuery and React -- Delete when Share is moved to Edit
      tileManager.changeTileStatus(newStatus, this.state.activeStatus, count);
    }
  }

  tileContainerClick(tile, e) {
    e.preventDefault();
    const targetClass = e.target.classList;
    const parentElem = e.target.parentElement;
    if (helpers.unhandledClick(e)) {
      return; // eslint-disable-line
    } else if (parentElem.classList.contains('delete_tile') || targetClass.contains('delete_tile') || parentElem.classList.contains('destroy')) {
      this.handleMenuAction(tile, 'delete');
    } else if (targetClass.contains('ignore') || targetClass.contains('undo_ignore')) {
      this.changeTileStatus(tile, (targetClass.contains('ignore') ? 'ignored' : 'user_submitted'));
    } else if (targetClass.contains('update_status')) {
      this.changeTileStatus(tile);
    } else if (parentElem.classList.contains('edit') || targetClass.contains('edit')) {
      const tileForm = window.Airbo.TileFormModal;
      tileForm.init(window.Airbo.TileManager);
      tileForm.open(tile.editPath);
    } else {
      window.Airbo.TileThumbnail.getPreview(tile.tileShowPath, tile.id);
    }
  }

  handleMenuAction(tile, action) {
    if (action === 'post' || action === 'delete') {
      const actionConfirm = {
        post: (actTile, component) => { component.changeTileStatus(actTile, 'active'); },
        delete: (actTile, component) => { component.handleMenuAction(actTile, 'deleteConfirm'); },
      };
      this.triggerModal({
        ...constants[`${action}_MENU_ALERT_TEXT`],
        onConfirm: () => { actionConfirm[action](tile, this); this.setState({alert: null }); },
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
      this.getAdditionalTiles({tileStatusNav: newTileStatusNav, loading: true}, 'filter');
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

  // Hacky patch to hold jQuery and React together until builder is overhauled
  tileBuilderPatch(event, payload) {
    try {
      const tile = new TileManager(parseInt(payload.tileId, 10), this);
      if (event.type === "/tile-admin/tile-deleted") {
        tile.removeTileFromCollection();
      } else {
        tile.refresh();
      }
    } catch (e) {
      TileManager.fetchNewTile(payload.tileId, this);
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
