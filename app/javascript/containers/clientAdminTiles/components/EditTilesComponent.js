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

const getTileCalIcon = (activeStatus, tile) => {
  if (activeStatus === 'active' || activeStatus === 'archive') { return 'fa-calendar'; }
  return tile[`${activeStatus}Date`] ? 'fa-calendar-check-o' : 'fa-calendar-times-o';
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

const buttonsPerStatus = {
  plan: args => args.tile.fullyAssembled ? [ReadyToSendBtn(args, 1)] : [IncompleteEditBtn(args, 1), DirectDestroyBtn(args, 2)],
  active: args => [ArchiveBtn(args, 3)],
  archive: args => [UnarchiveBtn(args, 5)],
  draft: args => [BackToPlanBtn(args, 8)],
  user_submitted: args => args.tile.ignored ? [UndoIgnoreBtn(args, 13), DirectDestroyBtn(args, 21)] : [AcceptBtn(args, 34), IgnoreBtn(args, 55)],
};

const renderTileButtons = args => {
  const result = buttonsPerStatus[args.activeStatus](args);
  if (['plan', 'draft', 'active', 'archive'].indexOf(args.activeStatus) > -1 && args.tile.fullyAssembled) {
    result.push(React.createElement(PopdownButtonComponent, {
      key: 89,
      containerElement: 'li',
      containerProps: {className: 'pill more right', key: 144},
      dropdownId: args.tile.id,
    }));
    result.push(EditBtn(args, 233));
  }
  return result;
};

const renderStatButtons = tile => {
  const faIcon = {unique_views: 'users', views: 'eye', completions: 'check'};
  return ["unique_views", "views", "completions"].map((statType, key) => (
    React.createElement('div', {
      className: `${statType} stat_action js-open-tile-stats-modal`,
      'data-tile-id': tile.id,
      'data-href': `/client_admin/tiles/${tile.id}/tile_stats`,
      key,
    },
      React.createElement("i", {className: `fa fa-${faIcon[statType]}`}),
      tile[statType],
    )
  ));
};

const renderTiles = (
  tiles,
  activeStatus,
  changeTileStatus,
  tileContainerClick,
  handleMenuAction,
  moveTile,
  sortTile,
  activeFilters,
) => (
  fillInTileContainers(tiles.map((tile, index) => (
    React.createElement(DraggableTile, {
      key: tile.id,
      index,
      date: !tile.fullyAssembled ? 'Incomplete' : sanitizeDate(activeStatus, tile[`${activeStatus}Date`]),
      caledarIcon: !tile.fullyAssembled ? 'fa-cog' : getTileCalIcon(activeStatus, tile),
      calendarClass: (!tile.fullyAssembled ? 'incomplete' : ''),
      tileContainerClass: activeStatus,
      tileThumblinkClass: 'tile_thumb_link tile_thumb_link_client_admin',
      shadowOverlayButtons: renderTileButtons({activeStatus, changeTileStatus, tile}),
      popdownMenu: renderPopdownMenu({activeStatus, tile, handleMenuAction}),
      loading: tile.loading,
      tileThumblinkOnClick: (e) => { tileContainerClick(tile, e); },
      tileStats: ["active", "archive"].indexOf(activeStatus) > -1 ? renderStatButtons(tile) : null,
      activeFilters,
      moveTile,
      sortTile,
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
            props.moveTile,
            props.sortTile,
            props.tileStatusNav[props.activeStatus].filter,
          )}
        </div>
      </div>
    </div>
    <CustomDragLayer />
  </section>
);

const tileShape = {
  tiles: PropTypes.array,
  count: PropTypes.number,
};

const filterShape = {
  month: PropTypes.object,
  year: PropTypes.object,
  campaign: PropTypes.object,
  sortType: PropTypes.object,
};

const tileStatusNavShape = {
  tileCount: PropTypes.number,
  page: PropTypes.number,
  filter: PropTypes.shape(filterShape),
  uiDisplay: PropTypes.string,
};

EditTilesComponent.propTypes = {
  activeStatus: PropTypes.string.isRequired,
  changeTileStatus: PropTypes.func.isRequired,
  tiles: PropTypes.shape({
    user_submitted: PropTypes.shape(tileShape),
    plan: PropTypes.shape(tileShape),
    draft: PropTypes.shape(tileShape),
    share: PropTypes.shape(tileShape),
    active: PropTypes.shape(tileShape),
    archive: PropTypes.shape(tileShape),
  }),
  tileStatusNav: PropTypes.shape({
    user_submitted: PropTypes.shape(tileStatusNavShape),
    plan: PropTypes.shape(tileStatusNavShape),
    draft: PropTypes.shape(tileStatusNavShape),
    share: PropTypes.shape(tileStatusNavShape),
    active: PropTypes.shape(tileStatusNavShape),
    archive: PropTypes.shape(tileStatusNavShape),
  }),
  tileContainerClick: PropTypes.func,
  handleMenuAction: PropTypes.func,
  moveTile: PropTypes.func,
  sortTile: PropTypes.func,
};

export default EditTilesComponent;
