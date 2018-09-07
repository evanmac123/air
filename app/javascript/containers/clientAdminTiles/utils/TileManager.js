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

const updateJquerySend = (count, draft) => { // Extraneous code used to patch connection between jQuery and React -- Delete when Share is moved to Edit
  const number = draft ? count + 1 : count - 1;
  window.Airbo.PubSub.publish("updateShareTabNotification", { number });
};

class TileManager {
  constructor(tileId, reactComp) {
    this.tileId = tileId;
    this.reactComp = reactComp;
    this.tileData = getTileData(tileId, reactComp);
    this.loading = this.loading.bind(this);
    this.handleOpts = this.handleOpts.bind(this);
    this.changeTileStatus = this.changeTileStatus.bind(this);
    this.addTileToCollection = this.addTileToCollection.bind(this);
    this.removeTileFromCollection = this.removeTileFromCollection.bind(this);
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

  handleOpts(opts) {
    Object.keys(opts).forEach(key => {
      if (key === 'setLoadingTo') { this.tileData.selectTile.loading = opts[key]; }
    });
  }

  loading() {
    this.tileData.selectTile.loading = true;
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  changeTileStatus(newStatus, activeStatus, count) {
    updateTileStatus(this.tileId, newStatus, () => {
      if (activeStatus === 'plan' || activeStatus === 'draft') { updateJquerySend(count, newStatus === 'draft'); }
      if (newStatus === 'ignored' || newStatus === 'user_submitted') {
        this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles[this.tileData.selectTileIndex].ignored = newStatus === 'ignored';
      } else {
        this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles.splice(this.tileData.selectTileIndex, 1);
        this.tileData.stateTiles[this.reactComp.state.activeStatus].count -= 1;
        this.tileData.stateTiles[newStatus].tiles.unshift(this.tileData.selectTile);
        this.tileData.stateTiles[newStatus].count += 1;
      }
      this.reactComp.setState({ tiles: this.tileData.stateTiles });
    });
  }

  addTileToCollection(newTile, opts) {
    this.handleOpts(opts);
    this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles.unshift(newTile);
    this.tileData.stateTiles[this.reactComp.state.activeStatus].count += 1;
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  removeTileFromCollection() {
    this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles.splice(this.tileData.selectTileIndex, 1);
    this.tileData.stateTiles[this.reactComp.state.activeStatus].count -= 1;
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  refresh() {
    this.tileData.selectTile.loading = true;
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
    fetchTileJson(this.tileId, resp => {
      const tiles = {...this.tileData.stateTiles};
      tiles[this.reactComp.state.activeStatus].tiles[this.tileData.selectTileIndex] = {...resp, loading: false};
      this.reactComp.setState({ tiles });
    });
  }
}

export default TileManager;
