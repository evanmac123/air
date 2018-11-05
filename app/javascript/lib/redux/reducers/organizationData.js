import { SET_ORGANIZATION_DATA } from "../actionTypes";

const initialState = {
  name: '',
  tilesWording: 'Tiles',
  pointsWording: 'Points',
};

export default function(state = initialState, action) {
  switch (action.type) {
    case SET_ORGANIZATION_DATA: {
      return {
        ...state,
        ...action.payload,
      };
    }
    default:
      return state;
  }
}
