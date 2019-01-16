import React from 'react';
import PropTypes from "prop-types";

import { htmlSanitizer } from '../../../lib/helpers';

const determineIfMarkedComplete = (tileOrigin, tileComplete) => (
  tileOrigin === 'complete' || tileComplete ? 'completed' : 'not_completed'
);

const fontColorBasedOnBackground = ribbonColor => {
  let hex = ribbonColor.slice(1);
  if (hex.length === 3) {
    hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
  }
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  return (r * 0.299 + g * 0.587 + b * 0.114) > 186 ? '#000000' : '#FFFFFF';
};

const hideRibbonTag = () => {
  const ribbonTagElem = document.getElementById("ribbon-tag");
  if (!ribbonTagElem) { return; } // eslint-disable-line
  const fillBar = () => {
    const cur = parseFloat(ribbonTagElem.style.opacity);
    window.setTimeout(() => {
      if (cur > 0) {
        ribbonTagElem.style.opacity = `${cur - .10}`;
        fillBar();
      } else if (cur <= 0) {
        ribbonTagElem.setAttribute("style", "display: none;");
      }
    }, 10);
  };
  fillBar();
};

const ribbonTagStyle = ribbonColor => ({
  backgroundColor: ribbonColor,
  height: '45px',
  position: 'absolute',
  bottom: '0%',
  padding: '13px 1vw 0px 1vw',
  opacity: '1',
});

const ribbonTagTextStyle = ribbonColor => ({
  color: fontColorBasedOnBackground(ribbonColor),
  fontSize: '1.1rem',
  fontWeight: '100',
  letterSpacing: '0.3px',
});

const ribbonTagArrowBase = {
  width: '0',
  height: '0',
  borderLeft: '22px solid transparent',
  borderRight: '22px solid transparent',
  position: 'absolute',
  right: '-22px',
};

const ribbonTagArrowTop = ribbonColor => Object.assign({
  borderBottom: `22px solid ${ribbonColor}`,
  bottom: '0',
}, ribbonTagArrowBase);

const ribbonTagArrowBottom = ribbonColor => Object.assign({
  borderTop: `22px solid ${ribbonColor}`,
  top: '0',
}, ribbonTagArrowBase);

const renderRibbonTag = (ribbonTagName, ribbonTagColor, cb) => (
  <div id="ribbon-tag" style={ribbonTagStyle(ribbonTagColor)} onClick={cb}>
    <span className="ribbon-text" style={ribbonTagTextStyle(ribbonTagColor)}>
      {ribbonTagName}
    </span>
    <div style={ribbonTagArrowTop(ribbonTagColor)}></div>
    <div style={ribbonTagArrowBottom(ribbonTagColor)}></div>
  </div>
);

const TileImageComponent = props => (
  <div className={determineIfMarkedComplete(props.tileOrigin, props.tile.complete)}>
    {
      props.tile.embedVideo &&
      <div className="video_section" style={{display: 'block'}}>
        <span dangerouslySetInnerHTML={htmlSanitizer(props.tile.embedVideo)} />
        {props.tile.ribbonTagName &&
          renderRibbonTag(props.tile.ribbonTagName, props.tile.ribbonTagColor, hideRibbonTag)
        }
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
            renderRibbonTag(props.tile.ribbonTagName, props.tile.ribbonTagColor)
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
