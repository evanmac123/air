import React from "react";
import PropTypes from "prop-types";

const SelectedCampaignComponent = props => (
  <div>
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
          <p>{props.selectedCampaign.description}</p>
        </div>
      </div>
    </div>

    <div className="row">
      <div className="columns large-12">
        <div className="button js-copy-all-tiles-button" style={{margin: "10px"}}>
          Copy Campaign
        </div>
      </div>
    </div>

    <div className="explore-tiles-container with-divider">
      <div className="row">
        <div className="large-12 columns">
          <div className="tile_container explore">
            <div className="tile_thumbnail" id={`single-tile-${props.tiles[0].id}`}>
              <div className="tile-wrapper">
                <a href="link_to presenter.show_tile_path" className='tile_thumb_link_explore'>
                  <div className="tile_thumbnail_image">
                    <img src={props.tiles[0].thumbnail} />
                  </div>
                  <div className="activation_dates">
                    <span className='tile-active-time'>
                      <i className='fa fa-calendar'></i>
                      {props.tiles[0].created_at}
                    </span>
                  </div>
                  <div className="headline">
                    <div className="text">
                      {props.tiles[0].headline}
                    </div>
                  </div>
                  <div className="shadow_overlay"></div>
                  <div className="tile_overlay"></div>
                </a>

                <ul className="tile_buttons">
                  <li className="explore_copy_button">
                    <a href="explore_copy_tile_path(tile_id: presenter.id, path: :via_explore_page_tile_view)" className="button outlined explore_copy_link">
                      <span className="explore_thumbnail_copy_text">
                        Copy
                      </span>
                    </a>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
);

SelectedCampaignComponent.propTypes = {
  selectedCampaign: PropTypes.shape({
    name: PropTypes.string,
    description: PropTypes.string,
  }),
  tiles: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    thumbnail: PropTypes.string,
    created_at: PropTypes.string,
    headline: PropTypes.string,
  })),
};

export default SelectedCampaignComponent;
