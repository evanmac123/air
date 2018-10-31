import { SET_USER_DATA, SET_TILES_DATA, UPDATE_TILE_DATA, SET_ORGANIZATION_DATA } from "./actionTypes";

export const setUserData = content => ({
  type: SET_USER_DATA,
  payload: { ...content },
});

export const setTilesData = tiles => ({
  type: SET_TILES_DATA,
  payload: { ...tiles },
});

export const updateTileData = tile => ({
  type: UPDATE_TILE_DATA,
  payload: { ...tile },
});

export const setOrganizationData = organization => ({
  type: SET_ORGANIZATION_DATA,
  payload: { ...organization },
});
