import { SET_TILES_DATA, UPDATE_TILE_DATA, ADD_TILES_TO_STORE } from "../actionTypes";

const initialState = {
  incomplete: { order: [], count: 0 },
  complete: { order: [], count: 0 },
  explore: { order: [], count: 0 },
  edit: { order: [], count: 0 },
};


const sanitizeTiles = (tiles, state) => (
  /* eslint-disable no-param-reassign */
  tiles.reduce((result, tile) => {
    const exisitingData = state[tile.id] ? {...state[tile.id]} : {};
    result.order.push(tile.id);
    result.count++;
    result[tile.id] = Object.assign(tile, exisitingData);
    return result;
  }, { order: [], count: 0 })
  /* eslint-enable */
);

const parseTilePayload = (payload, state) => (
  Object.keys(payload).reduce((result, tileType) => {
    const sanitized = {};
    sanitized[tileType] = sanitizeTiles(payload[tileType], state[tileType]);
    return Object.assign(sanitized, result);
  }, {})
);

const updateSingleTileDate = (payload, state) => {
  const newTileData = {};
  newTileData[payload.origin] = {...state[payload.origin]};
  newTileData[payload.origin][payload.id] = {
    ...state[payload.origin][payload.id],
    ...payload.resp,
    fullyLoaded: true,
  };
  return newTileData;
};

const mergeNewDataWithState = (newTiles, state) => Object.keys(newTiles).reduce((result, tileType) => {
  const merged = {};
  merged[tileType] = {
    ...state[tileType],
    ...newTiles[tileType],
    order: state[tileType].order.concat(newTiles[tileType].order),
    count: state[tileType].count + newTiles[tileType].count,
  };
  return Object.assign(merged, result);
}, {});

export default function(state = initialState, action) {
  switch (action.type) {
    case SET_TILES_DATA: {
      const newTileState = parseTilePayload(action.payload, state);
      return {
        ...state,
        ...newTileState,
      };
    }
    case UPDATE_TILE_DATA: {
      const newTileData = updateSingleTileDate(action.payload, state);
      return {
        ...state,
        ...newTileData,
      };
    }
    case ADD_TILES_TO_STORE: {
      const sanitizedTileData = parseTilePayload(action.payload, state);
      const newTileData = mergeNewDataWithState(sanitizedTileData, state);
      return {
        ...state,
        ...newTileData,
      };
    }
    default:
      return state;
  }
}
