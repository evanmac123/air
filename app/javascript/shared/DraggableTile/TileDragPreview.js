import React from "react";
import PropTypes from "prop-types";

const TileDragPreview = props => (
  <div className="tile_prvw_container">
    <div className="tile_thumbnail" id={`single-tile-${props.id}`}>
      <div className="tile-wrapper">
        <div className="tile_thumbnail_image">
          <img src={props.thumbnail} />
        </div>
        {
          props.date &&
          <div className={`activation_dates ${props.calendarClass}`}>
            <span className='tile-active-time'>
              <i className={`fa ${props.caledarIcon}`}></i>
              {props.date}
            </span>
          </div>
        }
        <div className="headline">
          <div className="text">
            {props.headline}
          </div>
        </div>
        <div style={{height: '3px', backgroundColor: (props.campaignColor || '#fff')}}>
        </div>
        <div className="shadow_overlay">
        </div>
        <div className="tile_overlay"></div>
      </div>
    </div>
  </div>
);

TileDragPreview.propTypes = {
  id: PropTypes.number.isRequired,
  thumbnail: PropTypes.string.isRequired,
  headline: PropTypes.string.isRequired,
  caledarIcon: PropTypes.string,
  date: PropTypes.string,
  copyButtonDisplay: PropTypes.bool,
  calendarClass: PropTypes.string,
  campaignColor: PropTypes.string,
};

export default TileDragPreview;
