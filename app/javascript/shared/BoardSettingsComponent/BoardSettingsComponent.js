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
    this.syncSettingsState = this.syncSettingsState.bind(this);
    this.allSettingsComponents = [];
  }

  componentDidMount() {
    this.renderAllSettingsComponents();
    this.settingsData = Object.keys(this.props.settingsData).reduce((result, key) => (
      {...result, ...this.props.settingsData[key]}
    ), {});
  }

  componentDidUpdate() {
    if (this.state.loading) {this.setState({loading: false});}
  }

  componentWillUnmount() {
    this.props.onClose(this.settingsData);
  }

  syncSettingsState(data) {
    const oldData = {...this.settingsData};
    this.settingsData = {...oldData, ...data};
  }

  renderAllSettingsComponents() {
    const settingsComponentsKeys = Object.keys(this.props.settingsComponents).map(comp => comp);
    this.allSettingsComponents = settingsComponentsKeys.map((comp, key) => (
      React.createElement(this.props.settingsComponents[comp], {
        ...this.props.settingsData[comp],
        key,
        onUpdate: this.syncSettingsState,
      })
    ));
    this.setState({ settingsComponentsKeys });
  }

  render() {
    return (
      React.createElement('div', {className: 'board-settings-modal-wrapper'},
        React.createElement(SweetAlert, {
          title: "Board Settings",
          customClass: "airbo",
          showConfirm: false,
          onConfirm: this.props.unmountModal,
          onCancel: this.props.unmountModal,
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
          this.allSettingsComponents,
        ),
        React.createElement('span', {
          className: 'fa fa-times close-modal-cta',
          style: {
            position: 'fixed',
            right: '20%',
            top: '45%',
            fontSize: '32px',
            marginTop: '-250px',
            color: '#ffffff',
            zIndex: '5001',
          },
          onClick: this.props.unmountModal})
      )
    );
  }
}

BoardSettingsComponent.propTypes = {
  settingsComponents: PropTypes.object,
  settingsData: PropTypes.object,
  onClose: PropTypes.func.isRequired,
  unmountModal: PropTypes.func.isRequired,
};

export default BoardSettingsComponent;
