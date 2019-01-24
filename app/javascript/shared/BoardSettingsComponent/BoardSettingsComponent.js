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
    this.allSettingsComponents = settingsComponentsKeys.map((comp, key) => (
      React.createElement(this.props.settingsComponents[comp], {
        ...this.props.settingsData[comp],
        key,
        onClose: this.props.onClose,
      })
    ));
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
          marginTop: '-250px',
          height: '500px',
          overflow: 'scroll',
        },
      }, this.state.loading ?
        React.createElement(LoadingComponent) :
        this.allSettingsComponents
      )
    );
  }
}

BoardSettingsComponent.propTypes = {
  settingsComponents: PropTypes.object,
  settingsData: PropTypes.object,
  onClose: PropTypes.func.isRequired,
};

export default BoardSettingsComponent;
