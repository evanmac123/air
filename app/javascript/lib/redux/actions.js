import { SET_USER_DATA, SET_TILES_DATA } from "./actionTypes";

export const setUserData = content => ({
  type: SET_USER_DATA,
  payload: { ...content }
});

export const setTilesData = tiles => ({
  type: SET_TILES_DATA,
  payload: { ...tiles }
});
