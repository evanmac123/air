import React from "react";
import PropTypes from "prop-types";

const injectTooltipProps = dropdownId => {
  const result = {};
  result['data-tip'] = true;
  result['data-for'] = `dropdown-${dropdownId}`;
  result['data-event'] = 'click';
  return result;
};

const PopdownButtonComponent = props => (
  React.createElement(props.containerElement, {
    ...props.containerProps,
    ...injectTooltipProps(props.dropdownId),
    key: `dropdown-${props.dropdownId}`,
  },
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-0`}),
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-1`}),
    React.createElement('span', {className: 'dot', key: `${props.dropdownId}-2`}),
  )
);

PopdownButtonComponent.propTypes = {
  dropdownId: PropTypes.any.isRequired,
  containerElement: PropTypes.string.isRequired,
  containerProps: PropTypes.object,
};

export default PopdownButtonComponent;
