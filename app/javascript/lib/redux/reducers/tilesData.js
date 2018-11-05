import { SET_TILES_DATA, UPDATE_TILE_DATA } from "../actionTypes";

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

const updateSingleTileDate = (state, payload) => {
  const newTileData = {};
  newTileData[payload.origin] = {...state[payload.origin]};
  newTileData[payload.origin][payload.id] = {
    ...state[payload.origin][payload.id],
    ...payload.resp,
    fullyLoaded: true,
  };
  return newTileData;
};

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
      const newTileData = updateSingleTileDate(state, action.payload);
      return {
        ...state,
        ...newTileData,
      };
    }
    default:
      return state;
  }
}
