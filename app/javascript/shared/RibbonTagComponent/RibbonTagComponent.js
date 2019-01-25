import React from 'react';
import PropTypes from "prop-types";

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

const hideRibbonTag = hideIsActive => {
  if (hideIsActive) {
    const ribbonTagElem = document.getElementById("ribbon-tag");
    if (!ribbonTagElem) { return; } // eslint-disable-line
    const fadeOut = () => {
      const cur = parseFloat(ribbonTagElem.style.opacity);
      window.setTimeout(() => {
        if (cur > 0) {
          ribbonTagElem.style.opacity = `${cur - .10}`;
          fadeOut();
        } else if (cur <= 0) {
          ribbonTagElem.setAttribute("style", "display: none;");
        }
      }, 10);
    };
    fadeOut();
  }
};

const baseTagStyle = (color, height) => ({
  backgroundColor: color,
  height: `${height}px`,
  position: 'absolute',
  opacity: '1',
});

const ribbonTagStyle = props => {
  const base = baseTagStyle(props.ribbonTagColor, props.height);
  if (props.fullSizeTile) {
    return Object.assign({bottom: '0%', padding: '13px 1vw 0px 1vw'}, base);
  }
  return Object.assign({bottom: '123px', padding: '5px 1vw 0px 1vw', left: '0'}, base);
};

const ribbonTagTextStyle = props => ({
  color: fontColorBasedOnBackground(props.ribbonTagColor),
  fontSize: props.fullSizeTile ? '1.1rem' : '0.9rem',
  fontWeight: '100',
  letterSpacing: '0.3px',
});

const ribbonTagArrowBase = height => ({
  width: '0',
  height: '0',
  borderLeft: `${height/2}px solid transparent`,
  borderRight: `${height/2}px solid transparent`,
  position: 'absolute',
  right: `-${height/2}px`,
});

const ribbonTagArrowTop = props => Object.assign({
  borderBottom: `${props.height/2}px solid ${props.ribbonTagColor}`,
  bottom: '0',
}, ribbonTagArrowBase(props.height));

const ribbonTagArrowBottom = props => Object.assign({
  borderTop: `${props.height/2}px solid ${props.ribbonTagColor}`,
  top: '0',
}, ribbonTagArrowBase(props.height));

const RibbonTagComponent = props => (
  <div id="ribbon-tag" style={ribbonTagStyle(props)} onClick={() => hideRibbonTag(props.hideRibbonTag)}>
    <span className="ribbon-text" style={ribbonTagTextStyle(props)}>
      {props.ribbonTagName}
    </span>
    <div style={ribbonTagArrowTop(props)}></div>
    <div style={ribbonTagArrowBottom(props)}></div>
  </div>
);

RibbonTagComponent.propTypes = {
  height: PropTypes.string.isRequired,
  ribbonTagName: PropTypes.string.isRequired,
  ribbonTagColor: PropTypes.string.isRequired,
  hideRibbonTag: PropTypes.string,
  fullSizeTile: PropTypes.string,
};

export default RibbonTagComponent;
