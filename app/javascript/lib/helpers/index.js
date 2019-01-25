import MapWithIndex from "./MapWithIndex";
import Fetcher from "./Fetcher";
import WindowHelper from "./WindowHelper";
import LocalStorer from "./LocalStorer";
import InfiniScroller from "./InfiniScroller";
import DateMaker from "./DateMaker";
import htmlSanitizer from "./htmlSanitizer";
import SanitizeVarForRuby from "./SanitizeVarForRuby";

const Pluck = (array, key) => array.map(result => result[key]);

const Helper = {
  Pluck,
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

export {
  Pluck,
  MapWithIndex,
  Fetcher,
  WindowHelper,
  LocalStorer,
  InfiniScroller,
  DateMaker,
  htmlSanitizer,
  SanitizeVarForRuby,
};
