import React from 'react';
import PropTypes from 'prop-types';
import SweetAlert from 'react-bootstrap-sweetalert';

import { Fetcher } from '../../../lib/helpers';

class PotentialUserModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      userName: '',
      error: false,
      accountCreated: false,
    };
    this.saveNameValue = this.saveNameValue.bind(this);
    this.confirm = this.confirm.bind(this);
  }

  saveNameValue(e) {
    const userName = e.target.value;
    this.setState({ userName });
  }

  confirm() {
    if (this.state.userName) {
      Fetcher.xmlHttpRequest({
        method: 'POST',
        path: `/potential_user_conversions?potential_user_name=${this.state.userName}`,
        success: resp => {
          if (resp.error) {
            this.setState({ error: resp.error });
          } else {
            this.props.setUser(resp);
            this.setState({ accountCreated: true });
          }
        },
      });
    } else {
      this.setState({ error: 'Name cannot be blank' });
    }
  }

  render() {
    return this.state.accountCreated ? React.createElement(SweetAlert, {
      success: true,
      title: 'Account Successfully Created',
      onConfirm: this.props.onClose,
      style: {
        display: 'inherit',
        width: '50vw',
        marginLeft: '-28vw',
        marginTop: '-250px',
        height: '330px',
        overflow: 'scroll',
      }}, `Welcome to ${this.props.demoName}, ${this.state.userName}`) :
    React.createElement(SweetAlert, {
      title: `Welcome to ${this.props.demoName}`,
      confirmBtnText: "Submit",
      onConfirm: this.confirm,
      style: {
        display: 'inherit',
        width: '50vw',
        marginLeft: '-28vw',
        marginTop: '-250px',
        height: '330px',
        overflow: 'scroll',
      }},
      React.createElement('label', {
        style: {
          fontSize: '17px',
        },
      }, 'Enter your first and last name to continue:'),
      React.createElement('input', {
        onChange: this.saveNameValue,
        type: 'text',
        name: 'userName',
        style: {
          display: 'block',
          width: '60%',
          marginLeft: 'auto',
          marginRight: 'auto',
          border: this.state.error ? '1px solid red' : '',
        },
      }),
      (this.state.error ? React.createElement('span', {style: {color: 'red'}}, 'Name cannot be blank') : ''),
    );
  }
};

PotentialUserModal.propTypes = {
  setUser: PropTypes.func,
  onClose: PropTypes.func,
  demoName: PropTypes.string,
};

export default PotentialUserModal;
