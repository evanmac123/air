import { SET_USER_DATA } from "../actionTypes";

const initialState = {
  id: '',
  points: 0,
  incompleteTileNumber: 0,
  completedTileNumber: 0,
};

export default function(state = initialState, action) {
  switch (action.type) {
    case SET_USER_DATA: {
      return {
        ...state,
        ...action.payload,
      };
    }
    default:
      return state;
  }
}
