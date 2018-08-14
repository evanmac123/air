import React from "react";
import PropTypes from "prop-types";
import ReactTooltip from "react-tooltip";
import { MapWithIndex } from "../../lib/helpers";

const renderMenuElements = menuElements => (
  MapWithIndex(menuElements, (menuElement, index) => (
    React.createElement('li', {...menuElement, key: index}, menuElement.text)
  ))
);

const injectTooltipProps = dropdownId => {
  const result = {};
  result['data-tip'] = true;
  result['data-for'] = `dropdown-${dropdownId}`;
  return result;
};

const DropdownComponent = props => ([
  React.createElement(props.containerElement, {
    ...props.containerProps,
    ...injectTooltipProps(props.dropdownId),
  },
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-0`}),
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-1`}),
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-2`}),
  ),
  React.createElement(ReactTooltip, {
    id: `dropdown-${props.dropdownId}`,
    ariaHaspopup: 'true',
    role: 'dropdown',
  },
    React.createElement('ul',
      props.menuProps,
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
