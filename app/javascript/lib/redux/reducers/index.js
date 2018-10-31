import { combineReducers } from "redux";
import userData from "./userData";
import tilesData from "./tilesData";
import organizationData from "./organizationData";
import progressBarData from "./progressBarData";

export default combineReducers({
  userData,
  tilesData,
  organizationData,
  progressBarData,
});
