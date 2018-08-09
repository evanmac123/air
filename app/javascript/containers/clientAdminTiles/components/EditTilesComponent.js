import React from "react";
import PropTypes from "prop-types";

import TileComponent from "../../../shared/TileComponent";
import {
  ReadyToSendBtn,
  IncompleteEditBtn,
  DirectDestroyBtn,
  ArchiveBtn,
  UnarchiveBtn,
  BackToPlanBtn,
  AcceptBtn,
  IgnoreBtn,
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
    if (activeStatus === 'active' || activeStatus === 'archive') { return 'fa-calendar'; }
    return tile[`${activeStatus}Date`] ? 'fa-calendar-check-o' : 'fa-calendar-times-o';
  }
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
    // if (args.tile.fullyAssembled) {
    //   result.push(ActivateBtn(args, key += 1));
    // }
  }
  if (args.activeStatus === 'user_submitted') {
    result.push(AcceptBtn(args, key += 1));
    result.push(IgnoreBtn(args, key += 1));
  }
  return result;
};

const renderTiles = (tiles, activeStatus, changeTileStatus) => (
  fillInTileContainers(tiles.map(tile => (
    React.createElement(TileComponent, {
      key: tile.id,
      date: getTileCalInfo('date', activeStatus, tile),
      caledarIcon: getTileCalInfo('icon', activeStatus, tile),
      clientAdminButtons: true,
      changeStatusButton: 'Ready to Send',
      tileContainerClass: activeStatus,
      tileThumblinkClass: 'tile_thumb_link tile_thumb_link_client_admin',
      shadowOverlayButtons: renderTileButtons({activeStatus, changeTileStatus, tile}),
      ...tile,
      tileShowPath: '#',
    })
  )))
);

const EditTilesComponent = props => (
  <section className="manage_tiles js-ca-tiles-index-module-tab-content">
    <div className="row pt-2">
      <div className="large-12 columns">
        <div id={props.activeStatus}
          className="js-tiles-index-section">
          {renderTiles(props.tiles[props.activeStatus], props.activeStatus, props.changeTileStatus)}
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
};

export default EditTilesComponent;
