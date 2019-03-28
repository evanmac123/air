import * as actionTypes from "./actionTypes";

export const setUserData = content => ({
  type: actionTypes.SET_USER_DATA,
  payload: { ...content },
});

export const setTilesData = tiles => ({
  type: actionTypes.SET_TILES_DATA,
  payload: { ...tiles },
});

export const setTilesState = data => ({
  type: actionTypes.SET_TILES_STATE,
  payload: { ...data },
});

export const updateTileData = tile => ({
  type: actionTypes.UPDATE_TILE_DATA,
  payload: { ...tile },
});

export const addTilesToStore = tiles => ({
  type: actionTypes.ADD_TILES_TO_STORE,
  payload: { ...tiles },
});

export const setDemoData = demo => ({
  type: actionTypes.SET_DEMO_DATA,
  payload: { ...demo },
});

export const setOrganizationData = organization => ({
  type: actionTypes.SET_ORGANIZATION_DATA,
  payload: { ...organization },
});

export const setProgressBarData = data => ({
  type: actionTypes.SET_PROGRESS_BAR_DATA,
  payload: { ...data },
});

export const addCompletionAndPointsToProgressBar = data => ({
  type: actionTypes.ADD_COMPLETION_AND_POINTS_TO_PROGRESS_BAR,
  payload: { ...data },
});
