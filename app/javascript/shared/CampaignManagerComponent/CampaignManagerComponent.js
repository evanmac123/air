import React from "react";
import PropTypes from "prop-types";
import SweetAlert from 'react-bootstrap-sweetalert';

import LoadingComponent from "../LoadingComponent";
import ManagerMainComponent from "./components/ManagerMainComponent";
import CampaignFormComponent from "./components/CampaignFormComponent";
import constants from "./utils/constants";
import { Fetcher } from "../../lib/helpers";

const managerComponents = {
  ManagerMainComponent,
  CampaignFormComponent,
};

const getIndexOfCampaign = (id, campaigns) => {
  for (let index = 0; index < campaigns.length; index++) { if (campaigns[index].value === id) { return index; } }
  return false;
};

const sanitizeCampaignResponse = camp => (
  {label: camp.name, className: 'campaign-option', value: camp.id, color: camp.color, population: camp.population_segment_id}
);

class CampaignManagerComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      name: '',
      audience: null,
      color: '#ffb748',
      editCampaignId: '',
      loading: true,
      errorStyling: {},
      campaigns: [],
      activeComponent: 'ManagerMainComponent',
      populationSegments: [],
      errorMsg: '',
    };
    this.handleFormState = this.handleFormState.bind(this);
    this.submitCampaign = this.submitCampaign.bind(this);
    this.applyErrors = this.applyErrors.bind(this);
    this.setColorSelection = this.setColorSelection.bind(this);
    this.handleConfirm = this.handleConfirm.bind(this);
    this.updateCampaignState = this.updateCampaignState.bind(this);
    this.deleteCampaign = this.deleteCampaign.bind(this);
    this.editCampaign = this.editCampaign.bind(this);
    this.newCampaign = this.newCampaign.bind(this);
    this.removeCampaignFromState = this.removeCampaignFromState.bind(this);
    this.compareChanges = this.compareChanges.bind(this);
    this.campaignAbleToSave = this.campaignAbleToSave.bind(this);
    this.getFetcherOpts = this.getFetcherOpts.bind(this);
    this.alertProps = {
      CampaignFormComponent: {
        showCancel: true,
        confirmAction: this.submitCampaign,
      },
      ManagerMainComponent: {
        validationMsg: "You must enter your password!",
        title: "Manage Campaigns",
        showCancel: true,
        confirmBtnText: "+ Create Campaign",
        cancelBtnText: "Close",
        confirmAction: this.newCampaign,
        onCancel: () => { this.props.onClose(this.state.campaigns); },
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

  campaignAbleToSave() {
    return (this.state.name && this.state.audience && this.state.color && !this.state.loading && this.compareChanges());
  }

  getFetcherOpts() {
    return {
      params: {
        name: this.state.name,
        color: this.state.color,
        population_segment_id: this.state.audience.value === 'all' ? null : this.state.audience.value,
      },
      path: `${constants.BASE_URL}${this.state.editCampaignId ? this.state.editCampaignId : ''}`,
      method: this.state.editCampaignId ? 'PUT' : 'POST',
    };
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

  updateCampaignState(resp) {
    const campaigns = [...this.state.campaigns];
    const newCampaign = sanitizeCampaignResponse(resp.campaign);
    if (this.state.editCampaignId) {
      const index = getIndexOfCampaign(resp.campaign.id, campaigns);
      campaigns.splice(index, 1);
      campaigns.splice(index, 0, newCampaign);
    } else {
      campaigns.push(newCampaign);
    }
    this.setState({...constants.DEFAULT_STATE, campaigns});
  }

  submitCampaign() {
    if (this.campaignAbleToSave()) {
      const {params, path, method} = this.getFetcherOpts();
      this.setState({loading: true});
      Fetcher.xmlHttpRequest({
        method,
        path,
        params,
        success: this.updateCampaignState,
        err: () => {
          this.setState({...constants.DEFAULT_STATE, errorMsg: 'Campaign could not be created'});
        },
      });
    } else if (!this.compareChanges()) {
      this.setState({...constants.DEFAULT_STATE, errorMsg: 'No changes made to campaign'});
    } else {
      this.applyErrors();
    }
  }

  deleteCampaign(campId) {
    this.setState({errorMsg: ''});
    Fetcher.xmlHttpRequest({
      method: 'DELETE',
      path: `${constants.BASE_URL}${campId}`,
      success: this.removeCampaignFromState,
      err: () => { this.setState({errorMsg: "Cannot delete campaign while it's active"}); },
    });
  }

  newCampaign() {
    this.setState({
      ...constants.DEFAULT_STATE,
      activeComponent: 'CampaignFormComponent',
      color: '#ffb748',
      errorMsg: '',
    });
  }

  editCampaign(campaign) {
    let audience = {label: 'All Users', value: 'all'};
    for (let index = 0; index < this.state.populationSegments.length; index++) {
      if (this.state.populationSegments[index].value === campaign.population) {
        audience = this.state.populationSegments[index];
        break;
      }
    }
    this.setState({
      activeComponent: 'CampaignFormComponent',
      name: campaign.label,
      editCampaignId: campaign.value,
      audience,
      color: campaign.color,
      errorStyling: {},
      errorMsg: '',
    });
  }

  setColorSelection(colorChange) {
    this.setState(colorChange);
  }

  handleConfirm(cb) {
    if (cb) {
      cb();
    } else {
      this.props.onClose(this.state.campaigns);
    }
  }

  compareChanges() {
    if (!this.state.editCampaignId) { return true; }
    const existingCampaign = this.state.campaigns[getIndexOfCampaign(this.state.editCampaignId, this.state.campaigns)];
    const sanitizedAudience = this.state.audience && this.state.audience.value === 'all' ? null : this.state.audience;
    return (
      this.state.name !== existingCampaign.label ||
      this.state.color !== existingCampaign.color ||
      sanitizedAudience !== existingCampaign.population
    );
  }

  render() {
    return (
      React.createElement(SweetAlert, {
        title: this.state.editCampaignId ? "Edit Campaign" : "Create Campaign",
        confirmBtnText:  this.state.editCampaignId ? "Save Changes" : "Create Campaign",
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
          editCampaign: this.editCampaign,
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
