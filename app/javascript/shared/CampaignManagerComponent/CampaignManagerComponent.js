import React, { Component } from "react";
import PropTypes from "prop-types";

import NewCampaignComponent from "./components/NewCampaignComponent";
import { Fetcher } from "../../lib/helpers";

const managerComponents = {
  NewCampaignComponent,
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
      activeComponent: 'NewCampaignComponent',
    };
    this.handleFormState = this.handleFormState.bind(this);
    this.submitCampaign = this.submitCampaign.bind(this);
    this.applyErrors = this.applyErrors.bind(this);
    this.populateCampaigns = this.populateCampaigns.bind(this);
    this.setColorSelection = this.setColorSelection.bind(this);
    this.populationSegments = [{label: 'All Users', value: 'all'}];
  }

  componentDidMount() {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/population_segments',
      method: 'GET',
      success: resp => {
        resp.forEach(popSeg => { this.populationSegments.push({label: popSeg.name, value: popSeg.id}); });
        this.populateCampaigns();
      },
    });
  }

  populateCampaigns() {
    if (this.props.campaigns.length) {
      this.props.campaigns.shift();
      const {campaigns} = this.props;
      this.setState({ loading: false, campaigns, populationSegments: this.populationSegments });
    } else {
      Fetcher.xmlHttpRequest({
        path: '/api/client_admin/campaigns',
        method: 'GET',
        success: resp => {
          const campaigns = resp.reduce((result, camp) => result.concat([{label: camp.campaign.name, className: 'campaign-option', value: camp.campaign.id}]), []);
          this.setState({ loading: false, campaigns, populationSegments: this.populationSegments });
        },
      });
    }
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
          this.props.onClose(resp);
        },
        err: () => { this.props.onClose(); },
      });
    } else {
      this.applyErrors();
    }
  }

  setColorSelection(color) {
    this.setState({ color });
  }

  render() {
    return (
      React.createElement(managerComponents[this.state.activeComponent], {
        ...this.state,
        setColorSelection: this.setColorSelection,
        submitCampaign: this.submitCampaign,
        handleFormState: this.handleFormState,
        onClose: this.props.onClose,
      })
    );
  }
}

CampaignManagerComponent.propTypes = {
  onClose: PropTypes.func.isRequired,
  campaigns: PropTypes.array,
};

export default CampaignManagerComponent;
