import { SET_PROGRESS_BAR_DATA, ADD_COMPLETION_AND_POINTS_TO_PROGRESS_BAR } from "../actionTypes";

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
    case ADD_COMPLETION_AND_POINTS_TO_PROGRESS_BAR: {
      const points = state.points + action.payload.points;
      const completedTiles = state.completedTiles + action.payload.completion;
      const raffleTickets = state.raffle ? Math.floor(points/20) : 0;
      return {
        ...state,
        points,
        completedTiles,
        raffleTickets,
      };
    }
    default:
      return state;
  }
}
