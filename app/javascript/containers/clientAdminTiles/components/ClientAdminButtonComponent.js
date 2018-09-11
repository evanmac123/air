import React from "react";
import PropTypes from "prop-types";

const renderData = rawData => (
  Object.keys(rawData).reduce((result, data) => {
    const insertData = {};
    insertData[`data-${data.split(/(?=[A-Z])/).join('-').toLowerCase()}`] = rawData[data];
    return Object.assign(insertData, result);
  }, {})
);

const ClientAdminButtonComponent = props => (
  React.createElement('li', {
    className: props.liClass,
    ...renderData(props.liData || {}),
  },
    React.createElement('span', {
      className: props.aClass,
      onClick: props.onClickAction,
      ...renderData(props.aData || {}),
    },
      (props.faIcon ? React.createElement('i', {className: `fa fa-${props.faIcon}`}) : props.buttonText),
      (props.spanText ? React.createElement('span', {}, props.spanText) : null),
    )
  )
);

ClientAdminButtonComponent.propTypes = {
  liClass: PropTypes.string,
  liData: PropTypes.object,
  aClass: PropTypes.string,
  onClickAction: PropTypes.func,
  aData: PropTypes.object,
  faIcon: PropTypes.string,
  buttonText: PropTypes.string,
  spanText: PropTypes.string,
};

export default ClientAdminButtonComponent;
