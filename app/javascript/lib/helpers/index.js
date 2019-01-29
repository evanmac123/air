import MapWithIndex from "./MapWithIndex";
import Fetcher from "./Fetcher";
import WindowHelper from "./WindowHelper";
import LocalStorer from "./LocalStorer";
import InfiniScroller from "./InfiniScroller";
import DateMaker from "./DateMaker";
import htmlSanitizer from "./htmlSanitizer";
import SanitizeVarForRuby from "./SanitizeVarForRuby";

export const Pluck = (array, key) => array.map(result => result[key]);
export const ObjectArraysExist = (obj, arrayKeys) => arrayKeys.map(key => (obj[key] && obj[key].length));
export { MapWithIndex };
export { Fetcher };
export { WindowHelper };
export { LocalStorer };
export { InfiniScroller };
export { DateMaker };
export { htmlSanitizer };
export { SanitizeVarForRuby };

const Helper = {
  Pluck,
  ObjectArraysExist,
  MapWithIndex,
  Fetcher,
  WindowHelper,
  LocalStorer,
  InfiniScroller,
  DateMaker,
  htmlSanitizer,
  SanitizeVarForRuby,
};

export default Helper;
