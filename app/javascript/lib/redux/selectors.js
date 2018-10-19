export const getSanitizedState = state => (
  { userData: state.userData, tiles: state.tilesData }
);
