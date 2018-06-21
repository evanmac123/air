import React from "react";
import PropTypes from "prop-types";

const displayCreationDate = date => {
  const splitDate = date.split("T")[0].split("-");
  return `${splitDate[1]}/${splitDate[2]}/${splitDate[0]}`;
};

const TileComponent = props => (
  <div className="tile_container explore">
    <div className="tile_thumbnail" id={`single-tile-${props.id}`}>
      <div className="tile-wrapper">
        <a href={props.tileShowPath} className='tile_thumb_link_explore'>
          <div className="tile_thumbnail_image">
            <img src={props.thumbnail} />
          </div>
          <div className="activation_dates">
            <span className='tile-active-time'>
              <i className='fa fa-calendar'></i>
              {displayCreationDate(props.created_at)}
            </span>
          </div>
          <div className="headline">
            <div className="text">
              {props.headline}
            </div>
          </div>
          <div className="shadow_overlay"></div>
          <div className="tile_overlay"></div>
        </a>

        <ul className="tile_buttons">
          <li className="explore_copy_button">
            <a
              onClick={() => props.copyTile({id: props.id, copyPath: props.copyPath})}
              className="button outlined explore_copy_link"
              id={props.id}
              data-tile-id={props.id}
              data-section="Explore"
            >
              <span className="explore_thumbnail_copy_text">
                Copy
              </span>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
);

TileComponent.propTypes = {
  id: PropTypes.number,
  thumbnail: PropTypes.string,
  created_at: PropTypes.string,
  headline: PropTypes.string,
  tileShowPath: PropTypes.string,
  copyPath: PropTypes.string,
  copyTile: PropTypes.func,
};

export default TileComponent;
