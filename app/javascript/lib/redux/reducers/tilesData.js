import { SET_TILES_DATA } from "../actionTypes";

const initialState = {
  incomplete: {},
  complete: {},
  explore: {},
  edit: {},
};

const sanitizeTiles = tiles => (
  tiles.reduce((result, tile) => {
    result[tile.id] = tile;
    return result;
  }, {})
)

const parseTilePayload = payload => (
  Object.keys(payload).reduce((result, tileType) => {
    const sanitized = {};
    sanitized[tileType] = sanitizeTiles(payload[tileType]);
    return Object.assign(sanitized, result);
  }, {})
);

export default function(state = initialState, action) {
  switch (action.type) {
    case SET_TILES_DATA: {
      const newTileState = parseTilePayload(action.payload);
      return {
        ...state,
        ...newTileState,
      };
    }
    default:
      return state;
  }
}
