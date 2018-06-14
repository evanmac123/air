import React from "react";
import PropTypes from "prop-types";

import TileComponent from "./TileComponent";

const renderTiles = tiles => tiles.map(tile => React.createElement(TileComponent, {...tile, key: tile.id}));

const renderHTML = html => html;

const SelectedCampaignComponent = props => (
  <div>
    <section className="campaign-header">
      <div className="row">
      <a onClick={props.navbarRedirect}>{"< Back to Explore"}</a>
        <div className="large-12 columns">
          <span className="explore-sub-page-header">{props.selectedCampaign.name}</span>
        </div>
      </div>
    </section>
    <div className="row">
      <div className="large-12 columns">
        <div className="campaign-description">
          <p
            dangerouslySetInnerHTML={{__html: renderHTML(props.selectedCampaign.description)}}
          />
        </div>
      </div>
    </div>
    {
      !(props.selectedCampaign.ongoing || props.user.isGuestUser || props.user.isEndUser) &&
      <div className="row">
        <div className="columns large-12">
          <div className="button js-copy-all-tiles-button" style={{margin: "10px"}}>
            Copy Campaign
          </div>
        </div>
      </div>
    }
    <div className="explore-tiles-container with-divider">
      <div className="row">
        <div className="large-12 columns">
          {renderTiles(props.tiles)}
        </div>
      </div>
    </div>
  </div>
);

SelectedCampaignComponent.propTypes = {
  selectedCampaign: PropTypes.shape({
    name: PropTypes.string,
    description: PropTypes.string,
    ongoing: PropTypes.bool,
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
  navbarRedirect: PropTypes.fn,
};

export default SelectedCampaignComponent;
