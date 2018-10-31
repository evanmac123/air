import { SET_PROGRESS_BAR_DATA } from "../actionTypes";

const initialState = {
  completedTiles: 0,
  incompletedTiles: 0,
  points: 0,
  raffleTickets: 0,
  loaded: false,
};

export default function(state = initialState, action) {
  switch (action.type) {
    case SET_PROGRESS_BAR_DATA: {
      return {
        ...state,
        ...action.payload,
      };
    }
    default:
      return state;
  }
}
