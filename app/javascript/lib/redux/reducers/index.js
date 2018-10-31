import { combineReducers } from "redux";
import userData from "./userData";
import tilesData from "./tilesData";
import organizationData from "./organizationData";

export default combineReducers({ userData, tilesData, organizationData });
