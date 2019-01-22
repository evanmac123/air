import React from "react";
import PropTypes from "prop-types";
import SweetAlert from 'react-bootstrap-sweetalert';

import LoadingComponent from "../LoadingComponent";

class BoardSettingsComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
      settingsComponentsKeys: [],
      activeSettingComponent: '',
    };
    this.allSettingsComponents = [];
  }

  componentDidMount() {
    this.renderAllSettingsComponents();
  }

  componentDidUpdate() {
    if (this.state.loading) {this.setState({loading: false});}
  }

  renderAllSettingsComponents() {
    const settingsComponentsKeys = Object.keys(this.props.settingsComponents).map(comp => comp);
    this.allSettingsComponents = settingsComponentsKeys.map((comp, key) => {
      return React.createElement(this.props.settingsComponents[comp], {
        key,
        ...this.props.settingsData[comp]
      });
    });
    this.setState({ settingsComponentsKeys });
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
          width: '56vw',
          marginLeft: '-28vw',
          minHeight: '340px',
        },
      }, this.state.loading ?
        React.createElement(LoadingComponent) :
        this.allSettingsComponents
      )
    );
  }
}

export default BoardSettingsComponent;
