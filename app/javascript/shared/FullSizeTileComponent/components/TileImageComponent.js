import React from 'react';
import PropTypes from "prop-types";

import { htmlSanitizer } from '../../../lib/helpers';

const determineIfMarkedComplete = (tileOrigin, tileComplete) => (
  tileOrigin === 'complete' || tileComplete ? 'completed' : 'not_completed'
);

const ribbonTagStyle = ribbonColor => ({
  backgroundColor: ribbonColor,
  height: '45px',
  position: 'absolute',
  bottom: '0%',
  padding: '13px 3vw 0px 1vw',
});

const ribbonTagTextStyle = ribbonColor => {
  return {
    color: 'white',
    fontSize: '1.1rem',
    fontWeight: '100',
    letterSpacing: '0.3px',
  };
};

const TileImageComponent = props => (
  <div className={determineIfMarkedComplete(props.tileOrigin, props.tile.complete)}>
    {
      props.tile.embedVideo &&
      <div className="video_section" style={{display: 'block'}}>
        <span dangerouslySetInnerHTML={htmlSanitizer(props.tile.embedVideo)} />
      </div>
    }

    {
      !props.tile.embedVideo &&
      <div className="image_section">
        <div className={`tile_full_image ${props.loading ? 'loading' : ''}`}>
          <img src={props.tile.imagePath} id="tile_img_preview" className="tile_image" alt={props.tile.headline} />
          <div className="shadow_overlay non-landing"></div>
          <div className="image_credit">
            {props.tile.imageCredit &&
              <div className="image_credit_view">
                <a href={props.tile.imageCredit} target="_blank" rel="noopener noreferrer">{props.tile.imageCredit}</a>
              </div>
            }
          </div>
          {props.tile.ribbonTagName &&
            <div className="ribbon-tag" style={ribbonTagStyle(props.tile.ribbonTagColor)}>
              <span className="ribbon-text" style={ribbonTagTextStyle(props.tile.ribbonTagColor)}>
                {props.tile.ribbonTagName}
              </span>
            </div>
          }
        </div>
      </div>
    }
    <div id="tileGrayOverlay" style={{display: 'none'}}></div>
  </div>
);

TileImageComponent.propTypes = {
  tileOrigin: PropTypes.string,
  tile: PropTypes.shape({
    embedVideo: PropTypes.string,
    imagePath: PropTypes.string,
    headline: PropTypes.string,
    imageCredit: PropTypes.string,
    ribbonTagName: PropTypes.string,
    ribbonTagColor: PropTypes.string,
    complete: PropTypes.bool,
  }),
  loading: PropTypes.bool,
};

export default TileImageComponent;
