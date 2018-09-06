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

  changeTileStatus(newState, opts) {
    this.handleOpts(opts);
    if (newState === 'ignored' || newState === 'user_submitted') {
      this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles[this.tileData.selectTileIndex].ignored = newState === 'ignored';
    } else {
      this.tileData.stateTiles[this.reactComp.state.activeStatus].tiles.splice(this.tileData.selectTileIndex, 1);
      this.tileData.stateTiles[this.reactComp.state.activeStatus].count -= 1;
      this.tileData.stateTiles[newState].tiles.unshift(this.tileData.selectTile);
      this.tileData.stateTiles[newState].count += 1;
    }
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
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
