import React from "react";
import PropTypes from "prop-types";
import ReactTooltip from "react-tooltip";
import { MapWithIndex } from "../../lib/helpers";

const renderMenuElements = menuElements => (
  MapWithIndex(menuElements, (menuElement, index) => (
    React.createElement('li', {
      ...menuElement.attrs,
      className: `${menuElement.attrs.className} popdown-item`,
      onClick: menuElement.clickEvent,
      key: index,
      style: {
        width: '100%',
        padding: '7px 0 7px 0',
        margin: '0 2vw 0 0',
        fontSize: '0.9rem',
        color: '#5c5c5c',
      },
    },
      (menuElement.faIcon ? React.createElement('i', {className: `fa fa-${menuElement.faIcon}`, style: {display: 'inline-block', paddingRight: '5%'}}) : null),
      React.createElement('span', {
        style: {
          display: 'inline-block',
          lineHeight: '18px',
          margin: '5px',
        },
      },
        menuElement.text),
    )
  ))
);


const MenuComponent = props => (
  React.createElement(ReactTooltip, {
    key: `tooltip-${props.dropdownId}`,
    id: `dropdown-${props.dropdownId}`,
    ariaHaspopup: 'true',
    role: 'dropdown',
    place: 'bottom',
    effect: 'solid',
    type: 'light',
    globalEventOff: 'click',
    afterShow: props.afterShow,
    afterHide: props.afterHide,
  },
    React.createElement('ul',
      {...props.menuProps, style: {pointerEvents: 'all'}, key: `ul-${props.dropdownId}`},
      renderMenuElements(props.menuElements),
    )
  )
);

MenuComponent.propTypes = {
  dropdownId: PropTypes.any.isRequired,
  menuProps: PropTypes.object,
  menuElements: PropTypes.array.isRequired,
  afterShow: PropTypes.func,
  afterHide: PropTypes.func,
};

export default MenuComponent;
