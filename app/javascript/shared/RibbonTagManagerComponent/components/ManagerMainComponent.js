import React from "react";
import PropTypes from "prop-types";

import RibbonTagFormComponent from "./RibbonTagFormComponent";

const cardStyle = {
  margin: '10px 0',
  padding: '10px',
  border: '1px solid #d8d8d8',
};

const textStyle = {
  float: 'left',
  margin: '14px 0px 0px 4%',
};

const circleButtonStyle = {
  width: '32px',
  height: '32px',
  border: '1px solid #999999',
  borderRadius: '50%',
  padding: '9px 0 9px 0',
  margin: '6px',
  float: 'right',
};

const iconStyle = {
  marginTop: '-3px',
  fontSize: '1.2rem',
};

const colorStyle = {
  width: '15px',
  height: '15px',
  borderRadius: '50%',
  margin: '14px 0 0 4%',
  float: 'left',
};

const errorMessage = (props, campId) => props.errorMsg && props.errorId === campId ?
  (
    <div
    style={{
      overflow: 'hidden',
      maxHeight: '100px',
      color: 'rgb(121, 121, 121)',
      fontSize: '16px',
      textAlign: 'center',
      fontWeight: '300',
      display: 'inline',
    }}
    >
      <div
        style={{
          display: 'inline-block',
          width: '24px',
          height: '24px',
          borderRadius: '50%',
          backgroundColor: 'rgb(234, 125, 125)',
          color: 'white',
          lineHeight: '24px',
          textAlign: 'center',
          marginRight: '5px',
        }}
      >!</div>
      {props.errorMsg}
    </div>
  ) : '';

const renderRibbonTagCards = props => (
  props.ribbonTags.map(ribbonTag => (
    React.createElement('div', {className: `campaign-card ${props.activeComponent === ribbonTag.value ? 'expand' : ''}`, style: cardStyle, key: ribbonTag.label},
      React.createElement('span', {style: {...colorStyle, backgroundColor: ribbonTag.color}}),
      React.createElement('span', {style: textStyle}, ribbonTag.label),
      errorMessage(props, ribbonTag.value),
      React.createElement('span', {className: 'circle-button', style: circleButtonStyle, onClick: () => { props.deleteRibbonTag(ribbonTag.value); }},
        React.createElement('i', {className: `fa fa-trash-o`, style: iconStyle})
      ),
      React.createElement('span', {className: 'circle-button', style: circleButtonStyle, onClick: () => { props.editRibbonTag(ribbonTag); }},
        React.createElement('i', {className: `fa fa-pencil`, style: iconStyle})
      ),
      React.createElement(RibbonTagFormComponent, {
        ...props,
        expanded: props.activeComponent === ribbonTag.value,
      })
    )
  ))
);

const ManagerMainComponent = props => (
  <div className={`audience-list ${props.expanded ? 'expand' : ''}`}>
    {renderRibbonTagCards(props)}
    </div>
);

ManagerMainComponent.propTypes = {
  ribbonTags: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]).isRequired,
    label: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  })).isRequired,
  deleteRibbonTag: PropTypes.func.isRequired,
  editRibbonTag: PropTypes.func.isRequired,
  errorMsg: PropTypes.string,
  errorId: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
  ]),
  expanded: PropTypes.bool,
};

export default ManagerMainComponent;
