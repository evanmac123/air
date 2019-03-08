import { SET_DEMO_DATA } from "../actionTypes";

const initialState = {
  name: '',
  customWelcomeMessage: null,
  email: '',
  publicSlug: '',
  isPublic: null,
  guestUserConversionModal: null,
  hideSocial: false
};

export default function(state = initialState, action) {
  switch (action.type) {
    case SET_DEMO_DATA: {
      return {
        ...state,
        ...action.payload,
      };
    }
    default:
      return state;
  }
}
