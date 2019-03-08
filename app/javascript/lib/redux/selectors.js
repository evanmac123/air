/* eslint-disable */
export const getSanitizedState = state => (
  {
    userData: state.userData,
    tiles: state.tilesData,
    demo: state.demoData,
    organization: state.organizationData,
    progressBarData: state.progressBarData,
  }
);
