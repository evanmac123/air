import React from "react";
import PropTypes from "prop-types";

import { DraggableTile, CustomDragLayer } from "../../../shared/DraggableTile";
import { PopdownMenuComponent, PopdownButtonComponent } from "../../../shared/PopdownMenu";
import { DateMaker } from "../../../lib/helpers";
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

const tileDropdownToggle = (tileId, toggle) => {
  if (toggle === 'show') {
    document.getElementById(`single-tile-${tileId}`).children[0].classList.add('active_menu');
  } else {
    document.getElementById(`single-tile-${tileId}`).children[0].classList.remove('active_menu');
  }
};

const sanitizeDate = (status, date) => {
  if (!date) { return status === 'plan' ? 'Unplanned' : null; }
  const splitDate = DateMaker.splitDate(date);
  if (status === 'plan' || status === 'user_submitted') {
    return `${splitDate.spelledOutMonth} ${splitDate.day}`;
  }
  return `${splitDate.monthNumber}/${splitDate.day}/${splitDate.fullYear}`;
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
  const amount = tileComponents.length ? (tileComponents.length % 4 ? (4 - (tileComponents.length % 4)) : 0) : 4; // eslint-disable-line
  for (let i = 0; i < amount; i++) {
    tileComponents.push(React.createElement('div', {className: 'tile_container placeholder_container', key: i},
      React.createElement('div', {className: 'tile_thumbnail placeholder_tile'})
    ));
  }
  return tileComponents;
};

const renderMenuButtons = args => {
  const result = [];
  if (args.activeStatus === 'draft') {
    result.push({
      attrs: {className: 'post_title', style: {width: '100%'}},
      faIcon: 'thumb-tack',
      text: 'Post',
      clickEvent: (e) => { args.handleMenuAction(args.tile, 'post', e); },
    });
  }
  result.push({
    attrs: {className: 'duplicate_tile', style: {width: '100%'}},
    faIcon: 'copy',
    text: 'Copy',
    clickEvent: (e) => { args.handleMenuAction(args.tile, 'copy', e); },
  });
  result.push({
    attrs: {className: 'delete_tile', style: {width: '100%'}},
    faIcon: 'trash-o',
    text: 'Delete',
    clickEvent: (e) => { args.handleMenuAction(args.tile, 'delete', e); },
  });
  return result;
};

const renderPopdownMenu = args => (
  React.createElement(PopdownMenuComponent, {
    dropdownId: args.tile.id,
    afterShow: () => { tileDropdownToggle(args.tile.id, 'show'); },
    afterHide: () => { tileDropdownToggle(args.tile.id, 'hide'); },
    menuProps: {className: 'tile_thumbnail_menu'},
    menuElements: renderMenuButtons(args),
  })
);


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
    result.push(React.createElement(PopdownButtonComponent, {
      key: key += 1,
      containerElement: 'li',
      containerProps: {className: 'pill more right', key: key += 1},
      dropdownId: args.tile.id,
    }));
    result.push(EditBtn(args, key += 4));
  }
  return result;
};

const renderTiles = (tiles, activeStatus, changeTileStatus, tileContainerClick, handleMenuAction, moveTile) => (
  fillInTileContainers(tiles.map((tile, index) => (
    React.createElement(DraggableTile, {
      key: tile.id,
      index,
      date: getTileCalInfo('date', activeStatus, tile),
      caledarIcon: getTileCalInfo('icon', activeStatus, tile),
      calendarClass: (!tile.fullyAssembled ? 'incomplete' : ''),
      tileContainerClass: activeStatus,
      tileThumblinkClass: 'tile_thumb_link tile_thumb_link_client_admin',
      shadowOverlayButtons: renderTileButtons({activeStatus, changeTileStatus, tile}),
      popdownMenu: renderPopdownMenu({activeStatus, tile, handleMenuAction}),
      loading: tile.loading,
      tileThumblinkOnClick: (e) => { tileContainerClick(tile, e); },
      moveTile,
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
            props.tiles[props.activeStatus].tiles,
            props.activeStatus,
            props.changeTileStatus,
            props.tileContainerClick,
            props.handleMenuAction,
            props.moveTile
          )}
        </div>
      </div>
    </div>
    <CustomDragLayer />
  </section>
);

EditTilesComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  changeTileStatus: PropTypes.func.isRequired,
  tiles: PropTypes.shape({
    user_submitted: PropTypes.shape({
      tiles: PropTypes.array,
      count: PropTypes.number,
    }),
    plan: PropTypes.shape({
      tiles: PropTypes.array,
      count: PropTypes.number,
    }),
    draft: PropTypes.shape({
      tiles: PropTypes.array,
      count: PropTypes.number,
    }),
    share: PropTypes.shape({
      tiles: PropTypes.array,
      count: PropTypes.number,
    }),
    active: PropTypes.shape({
      tiles: PropTypes.array,
      count: PropTypes.number,
    }),
    archive: PropTypes.shape({
      tiles: PropTypes.array,
      count: PropTypes.number,
    }),
  }),
  tileContainerClick: PropTypes.func,
  handleMenuAction: PropTypes.func,
};

export default EditTilesComponent;
