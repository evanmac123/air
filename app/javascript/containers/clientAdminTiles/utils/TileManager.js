const getTileData = (tileId, reactComp) => {
  const stateTiles = reactComp.state.tiles;
  for (let index = 0; index < stateTiles[reactComp.state.activeStatus].length; index++) {
    if (stateTiles[reactComp.state.activeStatus][index].id === tileId) {
      return {
        stateTiles,
        selectTile: stateTiles[reactComp.state.activeStatus][index],
        selectTileIndex: index,
      };
    }
  }
  throw new Error('Tile not found');
};

class TileManager {
  constructor(tileId, reactComp) {
    this.tileId = tileId;
    this.reactComp = reactComp;
    this.tileData = getTileData(tileId, reactComp);
    this.loading = this.loading.bind(this);
    this.changeTileStatus = this.changeTileStatus.bind(this);
  }

  loading() {
    this.tileData.selectTile.loading = true;
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }

  changeTileStatus(newState) {
    this.tileData.stateTiles[this.reactComp.state.activeStatus].splice(this.tileData.selectTileIndex, 1);
    this.tileData.stateTiles[newState].push(this.tileData.selectTile);
    this.reactComp.setState({ tiles: this.tileData.stateTiles });
  }
}

export default TileManager;
