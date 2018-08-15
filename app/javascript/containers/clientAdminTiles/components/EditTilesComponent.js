import React from "react";
import PropTypes from "prop-types";

import TileComponent from "../../../shared/TileComponent";
import DropdownComponent from "../../../shared/DropdownComponent";
import {
  ReadyToSendBtn,
  IncompleteEditBtn,
  DirectDestroyBtn,
  ArchiveBtn,
  UnarchiveBtn,
  BackToPlanBtn,
  AcceptBtn,
  IgnoreBtn,
  UndoIgnoreBtn,
  EditBtn,
} from "./buttonPresets";

const sanitizeDate = (status, date) => {
  if (!date) { return status === 'plan' ? 'Unplanned' : null; }
  const splitDate = date.split("T")[0].split("-");
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  if (status === 'plan' || status === 'user_submitted') {
    return `${months[splitDate[1] - 1]} ${splitDate[2]}`;
  }
  return `${splitDate[1]}/${splitDate[2]}/${splitDate[0]}`;
};

const getTileCalInfo = (type, activeStatus, tile) => {
  if (type === 'icon') {
    if (!tile.fullyAssembled) { return 'fa-cog'; }
    if (activeStatus === 'active' || activeStatus === 'archive') { return 'fa-calendar'; }
    return tile[`${activeStatus}Date`] ? 'fa-calendar-check-o' : 'fa-calendar-times-o';
  }
  if (!tile.fullyAssembled) { return 'Incomplete'; }
  return sanitizeDate(activeStatus, tile[`${activeStatus}Date`]);
};

const fillInTileContainers = tileComponents => {
  const amount = tileComponents.length ? (4 - (tileComponents.length % 4)) : 4;
  for (let i = 0; i < amount; i++) {
    tileComponents.push(React.createElement('div', {className: 'tile_container placeholder_container', key: i},
      React.createElement('div', {className: 'tile_thumbnail placeholder_tile'})
    ));
  }
  return tileComponents;
};

const renderMenuButtons = (args) => {
  const result = [];
  if (args.activeStatus === 'draft') {
    result.push({
      attrs: {className: 'post_title', style: {width: '100%'}},
      faIcon: 'thumb-tack',
      text: 'Post',
    });
  }
  result.push({
    attrs: {className: 'duplicate_tile', style: {width: '100%'}},
    faIcon: 'copy',
    text: 'Copy',
  });
  result.push({
    attrs: {className: 'delete_tile', style: {width: '100%'}},
    faIcon: 'trash-o',
    text: 'Delete',
  });
  return result;
};

const renderTileButtons = args => {
  const result = [];
  let key = 1;
  if (args.activeStatus === 'plan') {
    if (args.tile.fullyAssembled) {
      result.push(ReadyToSendBtn(args, key += 1));
    } else {
      result.push(IncompleteEditBtn(args, key += 1));
      result.push(DirectDestroyBtn(args, key += 1));
    }
  }
  if (args.activeStatus === 'active') {
    result.push(ArchiveBtn(args, key += 1));
  }
  if (args.activeStatus === 'archive') {
    result.push(UnarchiveBtn(args, key += 1));
  }
  if (args.activeStatus === 'draft') {
    result.push(BackToPlanBtn(args, key += 1));
  }
  if (args.activeStatus === 'user_submitted') {
    if (args.tile.ignored) {
      result.push(UndoIgnoreBtn(args, key += 1));
      result.push(DirectDestroyBtn(args, key += 1));
    } else {
      result.push(AcceptBtn(args, key += 1));
      result.push(IgnoreBtn(args, key += 1));
    }
  }
  if (['plan', 'draft', 'active', 'archive'].indexOf(args.activeStatus) >= 0 && args.tile.fullyAssembled) {
    result.push(React.createElement(DropdownComponent, {
      key: key += 1,
      containerElement: 'li',
      containerProps: {className: 'pill more right', key: key += 1},
      dropdownId: args.tile.id,
      afterShow: () => { args.tileDropdownToggle(args.tile.id, 'show'); },
      afterHide: () => { args.tileDropdownToggle(args.tile.id, 'hide'); },
      menuProps: {className: 'tile_thumbnail_menu', key: key += 1},
      menuElements: renderMenuButtons(args),
    }));
    result.push(EditBtn(args, key += 4));
  }
  return result;
};

const renderTiles = (tiles, activeStatus, changeTileStatus, tileDropdownToggle, tileContainerClick) => (
  fillInTileContainers(tiles.map(tile => (
    React.createElement(TileComponent, {
      key: tile.id,
      date: getTileCalInfo('date', activeStatus, tile),
      caledarIcon: getTileCalInfo('icon', activeStatus, tile),
      calendarClass: (!tile.fullyAssembled ? 'incomplete' : ''),
      tileContainerClass: activeStatus,
      tileThumblinkClass: 'tile_thumb_link tile_thumb_link_client_admin',
      shadowOverlayButtons: renderTileButtons({activeStatus, changeTileStatus, tile, tileDropdownToggle}),
      loading: tile.loading,
      tileThumblinkOnClick: (e) => { tileContainerClick(tile, e); },
      ...tile,
      tileShowPath: null,
    })
  )))
);

const EditTilesComponent = props => (
  <section className="manage_tiles js-ca-tiles-index-module-tab-content">
    <div className="row pt-2">
      <div className="large-12 columns">
        <div id={props.activeStatus}
          className="js-tiles-index-section">
          {renderTiles(
            props.tiles[props.activeStatus],
            props.activeStatus,
            props.changeTileStatus,
            props.tileDropdownToggle,
            props.tileContainerClick,
          )}
        </div>
      </div>
    </div>
  </section>
);

EditTilesComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  changeTileStatus: PropTypes.func.isRequired,
  tiles: PropTypes.shape({
    user_submitted:PropTypes.array,
    plan:PropTypes.array,
    draft:PropTypes.array,
    share:PropTypes.array,
    active:PropTypes.array,
    archive:PropTypes.array,
  }),
  tileContainerClick: PropTypes.func,
  tileDropdownToggle: PropTypes.func,
};

export default EditTilesComponent;
