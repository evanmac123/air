import React from "react";
import PropTypes from "prop-types";
import SweetAlert from 'react-bootstrap-sweetalert';

import LoadingComponent from "../LoadingComponent";

class BoardSettingsComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
    };
  }

  render() {
    return (
      React.createElement(SweetAlert, {
        title: "Board Settings",
        customClass: "airbo",
        showConfirm: false,
        onConfirm: () => { this.props.onClose({});} ,
        onCancel: () => { this.props.onClose({});} ,
        style: {
          display: 'inherit',
          width: '520px',
        },
      }, this.state.loading ?
        React.createElement(LoadingComponent) :
        React.createElement("h1", {
          ...this.state,
        }),
      )
    );
  }
}

export default BoardSettingsComponent;
