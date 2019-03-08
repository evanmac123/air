import { SET_PROGRESS_BAR_DATA, ADD_COMPLETION_AND_POINTS_TO_PROGRESS_BAR } from "../actionTypes";

const initialState = {
  startingPoints: 0,
  completedTiles: 0,
  incompletedTiles: 0,
  points: 0,
  raffleTickets: 0,
  raffleBarCompletion: 0,
  ticketThresholdBase: 0,
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
      const startingPoints = state.points;
      const points = state.points + action.payload.points;
      const completedTiles = state.completedTiles + action.payload.completion;
      const pointsTowardsTicket = points - state.ticketThresholdBase;
      const raffleTickets = state.raffle ? Math.floor(pointsTowardsTicket/20) : 0;
      const raffleBarCompletion = ((pointsTowardsTicket % 20) / 20) * 100;
      return {
        ...state,
        startingPoints,
        points,
        completedTiles,
        raffleTickets,
        raffleBarCompletion,
      };
    }
    default:
      return state;
  }
}
