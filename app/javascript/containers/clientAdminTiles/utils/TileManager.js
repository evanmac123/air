import constants from "./constants";
import { Fetcher } from "../../../lib/helpers";

const getTileData = (tileId, reactComp) => {
  const stateTiles = reactComp.state.tiles;
  for (let index = 0; index < stateTiles[reactComp.state.activeStatus].tiles.length; index++) {
    if (stateTiles[reactComp.state.activeStatus].tiles[index].id === tileId) {
      return {
        stateTiles,
        selectTile: stateTiles[reactComp.state.activeStatus].tiles[index],
        selectTileIndex: index,
      };
    }
  }
  throw new Error('Tile not found');
};

const fetchTileJson = (tileId, cb) => {
  Fetcher.xmlHttpRequest({
    path: `/api/client_admin/tiles/${tileId}`,
    method: 'GET',
    success: cb,
  });
};

const updateTileStatus = (tileId, newStatus, cb) => {
  Fetcher.xmlHttpRequest({
    method: 'PUT',
    path: `/api/client_admin/tiles/${tileId}`,
    params: { newStatus },
    success: cb,
  });
};

const paramsToString = params => (
  Object.keys(params).reduce((result, param) => (
    params[param] ? `${result}${param}=${params[param]}&` : result
  ), '').slice(0, -1)
);

const updateJquerySend = (count, draft) => { // Extraneous code used to patch connection between jQuery and React -- Delete when Share is moved to Edit
  const number = draft ? count + 1 : count - 1;
  window.Airbo.PubSub.publish("updateShareTabNotification", { number });
};

const performDbAction = (tileId, action, cb) => {
  Fetcher.xmlHttpRequest({
    method: constants.MENU_OPTS[action].method,
    path: `/api/client_admin/tiles/${tileId}/${constants.MENU_OPTS[action].url}`,
    success: cb,
  });
};

class TileManager {
  constructor(tileId, reactComp) {
    this.tileId = tileId;
    this.reactComp = reactComp;
    this.tileData = getTileData(tileId, reactComp);
    this.toggleLoading = this.toggleLoading.bind(this);
    this.handleOpts = this.handleOpts.bind(this);
    this.changeTileStatus = this.changeTileStatus.bind(this);
    this.addTileToCollection = this.addTileToCollection.bind(this);
    this.removeTileFromCollection = this.removeTileFromCollection.bind(this);
  }

  static fetchAllTiles(cb) {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/tiles',
      method: 'GET',
      success: resp => { cb(resp, constants.TILE_STATUS); },
    });
  }

  static fetchTilesWithParams(params, cb) {
    const path = `/api/client_admin/tiles/filter?${paramsToString(params)}`;
    Fetcher.xmlHttpRequest({
      path,
      method: 'GET',
      success: cb,
    });
  }

  static fetchNewTile(tileId, reactComp) {
    reactComp.setState({ loading: true });
    fetchTileJson(tileId, resp => {
      const tiles = {...reactComp.state.tiles};
      tiles.plan.tiles.unshift({...resp});
      tiles.plan.count += 1;
      reactComp.setState({ tiles, loading: false });
    });
  }

  static sortTiles(tileId, leftTileId) {
    Fetcher.xmlHttpRequest({
      method: 'POST',
      path: `/api/client_admin/tiles/${tileId}/sorts`,
      params: { sort: { left_tile_id: leftTileId } },
      success: () => null,
    });
  }

  handleOpts(opts) {
    Object.keys(opts).forEach(key => {
      if (key === 'setLoadingTo') { this.tileData.selectTile.loading = opts[key]; }
    });
  }

  toggleLoading() {
    this.tileData.selectTile.loading = !this.tileData.selectTile.loading;
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  removeSelectTileUsingIndex() {
    this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles.splice(this.tileData.selectTileIndex, 1);
    this.tileData.stateTiles[this.reactComp.state.activeStatus].count -= 1;
  }

  addTileTo(status, tile, save) {
    this.tileData.stateTiles[status].tiles.unshift(tile);
    this.tileData.stateTiles[status].count += 1;
    if (save) { this.toggleLoading(); }
  }

  changeTileStatus(newStatus, activeStatus, count) {
    updateTileStatus(this.tileId, newStatus, () => {
      if (activeStatus === 'plan' || activeStatus === 'draft') { updateJquerySend(count, newStatus === 'draft'); }
      if (newStatus === 'ignored' || newStatus === 'user_submitted') {
        this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles[this.tileData.selectTileIndex].ignored = newStatus === 'ignored';
      } else {
        this.removeSelectTileUsingIndex();
        this.addTileTo(newStatus, this.tileData.selectTile, 'save');
      }
      this.reactComp.setState({ tiles: this.tileData.stateTiles });
    });
  }

  addTileToCollection(newTile, opts) {
    this.handleOpts(opts);
    this.addTileTo(this.reactComp.state.activeStatus, newTile);
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  removeTileFromCollection() {
    this.removeSelectTileUsingIndex();
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  refresh() {
    this.toggleLoading();
    fetchTileJson(this.tileId, resp => {
      const tiles = {...this.tileData.stateTiles};
      tiles[this.reactComp.state.activeStatus].tiles[this.tileData.selectTileIndex] = {...resp};
      this.toggleLoading();
    });
  }

  performMenuAction(action) {
    const actions = {
      copy: resp => { this.addTileTo('plan', resp[0], 'save'); },
      deleteConfirm: () => { this.removeTileFromCollection(); },
    };
    this.toggleLoading();
    performDbAction(this.tileId, action, resp => { actions[action](resp); });
  }
}

export default TileManager;
