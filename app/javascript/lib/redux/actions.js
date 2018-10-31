import * as actionTypes from "./actionTypes";

export const setUserData = content => ({
  type: actionTypes.SET_USER_DATA,
  payload: { ...content },
});

export const setTilesData = tiles => ({
  type: actionTypes.SET_TILES_DATA,
  payload: { ...tiles },
});

export const updateTileData = tile => ({
  type: actionTypes.UPDATE_TILE_DATA,
  payload: { ...tile },
});

export const setOrganizationData = organization => ({
  type: actionTypes.SET_ORGANIZATION_DATA,
  payload: { ...organization },
});

export const setProgressBarData = data => ({
  type: actionTypes.SET_PROGRESS_BAR_DATA,
  payload: { ...data },
});
