import React from "react";
import SweetAlert from 'react-bootstrap-sweetalert';

import BoardSettingsComponent from "../../../shared/BoardSettingsComponent";
import CampaignManagerComponent from "../../../shared/CampaignManagerComponent";
import RibbonTagManagerComponent from "../../../shared/RibbonTagManagerComponent";
import { SanitizeVarForRuby } from "../../../lib/helpers";

const populateProps = (campaigns, ribbonTags, unmountModal, onClose) => {
  const props = { onClose, unmountModal };
  props.settingsComponents = campaigns ? { CampaignManagerComponent, RibbonTagManagerComponent } : { RibbonTagManagerComponent };
  props.settingsData = campaigns ? { CampaignManagerComponent: { campaigns }, RibbonTagManagerComponent: { ribbonTags }} : { RibbonTagManagerComponent: { ribbonTags } };
  return props;
};

export default {
  sanitizeTileData: rawTiles => {
    const result = {...rawTiles};
    result.user_submitted.tiles = result.user_submitted.tiles || [];
    rawTiles.ignored.tiles.forEach(tile => {
      result.user_submitted.tiles.push({...tile, ignored: true});
    });
    result.user_submitted.count += rawTiles.ignored.count;
    return result;
  },
  unhandledClick: e => (e.target.innerText === 'Copy' || e.target.innerText === 'Delete' || e.target.innerText === 'Post' ||
                              (e.target.classList.contains('pill') && e.target.classList.contains('more'))),
  purgeRepeatedTiles: (tileIDs, existingTiles, newTiles) => (
    newTiles.reduce((result, newTile) => {
      if (tileIDs.indexOf(newTile.id) < 0) { result.push(newTile); }
      return result;
    }, existingTiles)
  ),
  getFilterParams: statusFilter => (
    Object.keys(statusFilter).reduce((result, status) => (
      statusFilter[status] ? `${result}${SanitizeVarForRuby(status)}%3D${statusFilter[status].value}%26` : result
    ), '').slice(0, -3)
  ),
  sanitizeCampaignResponse: camp => (
    {label: camp.name, className: 'campaign-option', value: camp.id, color: camp.color, population: camp.population_segment_id}
  ),
  sanitizeRibbonTagResponse: tag => (
    {label: tag.name, className: 'ribbon-tag-option', value: tag.id, color: tag.color}
  ),
  swalModal: args => React.createElement(SweetAlert, args, args.text), // eslint-disable-line
  boardSettingsManager: (campaigns, ribbonTags, unmountModal, onClose) => React.createElement(
    BoardSettingsComponent,
    populateProps(campaigns, ribbonTags, unmountModal, onClose),
  ),
};
