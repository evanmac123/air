import React from "react";
import PropTypes from "prop-types";

import TileComponent from "../../../shared/TileComponent";
import NavbarComponent from "./NavbarComponent";
import LoadingComponent from "../../../shared/LoadingComponent";
import { htmlSanitizer } from '../../../lib/helpers';

const displayCreationDate = date => {
  const splitDate = date.split("T")[0].split("-");
  return `${splitDate[1]}/${splitDate[2]}/${splitDate[0]}`;
};

const renderTiles = (tiles, copyTile, user, openTileModal) => (
  tiles.map(tile => React.createElement(TileComponent, {
    ...tile,
    copyTile,
    user,
    key: tile.id,
    date: displayCreationDate(tile.created_at),
    copyButtonDisplay: true,
    caledarIcon: 'fa-calendar',
    tileContainerClass: 'explore',
    tileThumblinkClass: 'tile_thumb_link',
    tileThumblinkOnClick: () => { openTileModal(tile.id); },
    tileShowPath: null,
  }))
);

const SelectedCampaignComponent = props => (
  <div>
    <NavbarComponent navbarRedirect={props.navbarRedirect} />
    <section className="campaign-header">
      <div className="row">
        <div className="large-12 columns">
          <span className="explore-sub-page-header">{props.selectedCampaign.name}</span>
        </div>
      </div>
    </section>
    <div className="row">
      <div className="large-12 columns">
        <div className="campaign-description">
          <p dangerouslySetInnerHTML={htmlSanitizer(props.selectedCampaign.description)} />
        </div>
      </div>
    </div>
    {
      !(props.selectedCampaign.ongoing || props.user.isGuestUser || props.user.isEndUser) &&
      <div className="row">
        <div className="columns large-12">
          <div
            className="button"
            style={{margin: "10px"}}
            onClick={props.copyAllTiles}
          >
            {props.selectedCampaign.copyText}
          </div>
        </div>
      </div>
    }
    <div className="explore-tiles-container">
      <div className="row">
        <div className="large-12 columns">
          {renderTiles(props.tiles, props.copyTile, props.user, props.openTileModal)}
        </div>
      </div>
      { props.scrollLoading && <LoadingComponent /> }
    </div>
  </div>
);

SelectedCampaignComponent.propTypes = {
  selectedCampaign: PropTypes.shape({
    name: PropTypes.string,
    description: PropTypes.string,
    ongoing: PropTypes.bool,
    copyText: PropTypes.string,
  }),
  tiles: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    thumbnail: PropTypes.string,
    created_at: PropTypes.string,
    headline: PropTypes.string,
  })),
  user: PropTypes.shape({
    isGuestUser: PropTypes.bool,
    isEndUser: PropTypes.bool,
  }),
  navbarRedirect: PropTypes.func,
  copyAllTiles: PropTypes.func,
  copyTile: PropTypes.func,
  scrollLoading: PropTypes.bool,
  openTileModal: PropTypes.func,
};

export default SelectedCampaignComponent;
