import React from "react";
import PropTypes from "prop-types";
import ReactTooltip from "react-tooltip";
import { MapWithIndex } from "../../lib/helpers";

const renderMenuElements = menuElements => (
  MapWithIndex(menuElements, (menuElement, index) => (
    React.createElement('li', {...menuElement.attrs, key: index},
      (menuElement.faIcon ? React.createElement('i', {className: `fa fa-${menuElement.faIcon}`, style: {display: 'inline-block'}}) : null),
      React.createElement('span', {style: {display: 'inline-block'}}, menuElement.text),
    )
  ))
);

const injectTooltipProps = dropdownId => {
  const result = {};
  result['data-tip'] = true;
  result['data-for'] = `dropdown-${dropdownId}`;
  result['data-event'] = 'click';
  return result;
};

const DropdownComponent = props => ([
  React.createElement(props.containerElement, {
    ...props.containerProps,
    ...injectTooltipProps(props.dropdownId),
    key: `dropdown-${props.dropdownId}`,
  },
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-0`}),
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-1`}),
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-2`}),
  ),
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
      {...props.menuProps, key: `ul-${props.dropdownId}`},
      renderMenuElements(props.menuElements),
    )
  ),
]);

DropdownComponent.propTypes = {
  containerElement: PropTypes.string.isRequired,
  containerProps: PropTypes.object,
  dropdownId: PropTypes.any.isRequired,
  menuProps: PropTypes.object,
  menuElements: PropTypes.array.isRequired,
};

export default DropdownComponent;
