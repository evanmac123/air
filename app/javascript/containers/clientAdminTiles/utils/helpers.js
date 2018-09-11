import React from "react";
import SweetAlert from 'react-bootstrap-sweetalert';

import CampaignManagerComponent from "../../../shared/CampaignManagerComponent";

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
      statusFilter[status] ? `${result}${status}%3D${statusFilter[status].value}%26` : result
    ), '').slice(0, -3)
  ),
  sanitizeCampaignResponse: camp => (
    {label: camp.name, className: 'campaign-option', value: camp.id, color: camp.color, population: camp.population_segment_id}
  ),
  swalModal: args => React.createElement(SweetAlert, args, args.text), // eslint-disable-line
  campaignManager: (campaigns, onClose) => React.createElement(CampaignManagerComponent, {campaigns, onClose}), // eslint-disable-line
};
