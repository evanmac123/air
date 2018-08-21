import React, { Component } from "react";
import PropTypes from "prop-types";
import SweetAlert from 'react-bootstrap-sweetalert';

import LoadingComponent from "../LoadingComponent";
import ManagerMainComponent from "./components/ManagerMainComponent";
import NewCampaignComponent from "./components/NewCampaignComponent";
import { Fetcher } from "../../lib/helpers";

const managerComponents = {
  ManagerMainComponent,
  NewCampaignComponent,
};

const getIndexOfCampaign = (id, campaigns) => {
  for (let index = 0; index < campaigns.length; index++) { if (campaigns[index].value === id) { return index; } }
  return false;
};

class CampaignManagerComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: '',
      audience: '',
      color: '#ffb748',
      loading: true,
      errorStyling: {},
      campaigns: [],
      activeComponent: 'ManagerMainComponent',
    };
    this.handleFormState = this.handleFormState.bind(this);
    this.submitCampaign = this.submitCampaign.bind(this);
    this.applyErrors = this.applyErrors.bind(this);
    this.setColorSelection = this.setColorSelection.bind(this);
    this.handleConfirm = this.handleConfirm.bind(this);
    this.deleteCampaign = this.deleteCampaign.bind(this);
    this.removeCampaignFromState = this.removeCampaignFromState.bind(this);
    this.alertProps = {
      NewCampaignComponent: {
        title: "Create Campaign",
        confirmBtnText: "Create Campaign",
        showCancel: true,
        confirmAction: this.submitCampaign,
      },
      ManagerMainComponent: {
        title: "Manage Campaigns",
        showCancel: true,
        confirmBtnText: "+ Create Campaign",
        cancelBtnText: "Close",
        confirmAction: () => { this.setState({activeComponent: 'NewCampaignComponent'}); },
        onCancel: () => { this.props.onClose('close', this.state.campaigns); },
      },
    };
  }

  componentDidMount() {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/population_segments',
      method: 'GET',
      success: resp => {
        const populationSegments = resp.map(popSeg => ({label: popSeg.name, value: popSeg.id})).concat([{label: 'All Users', value: 'all'}]);
        const campaigns = [...this.props.campaigns];
        campaigns.shift();
        this.setState({ loading: false, campaigns, populationSegments });
      },
    });
  }

  applyErrors() {
    const errorStyling = {};
    if (!this.state.name) { errorStyling.name = {borderColor: 'red'}; }
    if (!this.state.audience) { errorStyling.audience = 'error'; }
    this.setState({ errorStyling });
  }

  handleFormState(field, val) {
    const newState = {};
    newState[field] = val;
    if (this.state.errorStyling[field]) {
      newState.errorStyling = {...this.state.errorStyling};
      newState.errorStyling[field] = null;
    }
    this.setState(newState);
  }

  removeCampaignFromState(campResp) {
    const campaigns = [...this.state.campaigns];
    campaigns.splice(getIndexOfCampaign(campResp.campaign.id, campaigns), 1);
    this.setState({ campaigns });
  }

  submitCampaign() {
    if (this.state.name && this.state.audience && this.state.color && !this.state.loading) {
      const params = {
        name: this.state.name,
        color: this.state.color,
        population_segment_id: this.state.audience === 'all' ? null : this.state.audience,
      };
      this.setState({loading: true});
      Fetcher.xmlHttpRequest({
        method: 'POST',
        path: `/api/client_admin/campaigns`,
        params,
        success: resp => {
          this.setState({
            name: '',
            audience: '',
            color: '#ffb748',
            loading: false,
            errorStyling: {},
          });
          this.props.onClose('create', resp);
        },
        err: () => { this.props.onClose('close', this.state.campaigns); },
      });
    } else {
      this.applyErrors();
    }
  }

  deleteCampaign(campId) {
    Fetcher.xmlHttpRequest({
      method: 'DELETE',
      path: `/api/client_admin/campaigns/${campId}`,
      success: this.removeCampaignFromState,
    });
  }

  setColorSelection(color) {
    this.setState({ color });
  }

  handleConfirm(cb) {
    if (cb) {
      cb();
    } else {
      this.props.onClose('close', this.state.campaigns);
    }
  }

  render() {
    return (
      React.createElement(SweetAlert, {
        cancelBtnText: "Back to Manage",
        onCancel: () => { this.setState({activeComponent: 'ManagerMainComponent'}); },
        ...this.alertProps[this.state.activeComponent],
        customClass: "airbo",
        cancelBtnCssClass: `cancel ${this.state.loading ? 'disabled' : ''}`,
        confirmBtnCssClass: `confirm ${this.state.loading ? 'disabled' : ''}`,
        onConfirm: () => { this.handleConfirm(this.alertProps[this.state.activeComponent].confirmAction); },
        style: {
          display: 'inherit',
          width: '520px',
        },
      }, this.state.loading ?
        React.createElement(LoadingComponent) :
        React.createElement(managerComponents[this.state.activeComponent], {
          ...this.state,
          setColorSelection: this.setColorSelection,
          handleFormState: this.handleFormState,
          deleteCampaign: this.deleteCampaign,
        }),
      )
    );
  }
}

CampaignManagerComponent.propTypes = {
  onClose: PropTypes.func.isRequired,
  campaigns: PropTypes.array,
};

export default CampaignManagerComponent;
