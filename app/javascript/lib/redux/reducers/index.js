import { combineReducers } from "redux";
import userData from "./userData";
import tilesData from "./tilesData";
import demoData from "./demoData";
import organizationData from "./organizationData";
import progressBarData from "./progressBarData";

export default combineReducers({
  userData,
  tilesData,
  demoData,
  organizationData,
  progressBarData,
});
