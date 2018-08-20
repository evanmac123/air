import React, { Component } from "react";
import PropTypes from "prop-types";
import Select from 'react-select';
import SweetAlert from 'react-bootstrap-sweetalert';
import LoadingComponent from "../../../shared/LoadingComponent";

import { Fetcher } from "../../../lib/helpers";

const colorOptionStyle = {
  cursor: 'pointer',
  height: '30px',
  width: '30px',
  borderRadius: '4px',
  marginRight: '10px',
  marginBottom: '5px',
  display: 'inline-block',
  float: 'left',
};

class CampaignCreatorComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      name: '',
      audience: '',
      color: '#ffb748',
      loading: true,
      errorStyling: {},
    };
    this.handleFormState = this.handleFormState.bind(this);
    this.submitCampaign = this.submitCampaign.bind(this);
    this.applyErrors = this.applyErrors.bind(this);
    this.populationSegments = [{label: 'All Users', value: 'all'}];
  }

  componentDidMount() {
    Fetcher.xmlHttpRequest({
      path: '/api/client_admin/population_segments',
      method: 'GET',
      success: resp => {
        resp.forEach(popSeg => { this.populationSegments.push({label: popSeg.name, value: popSeg.id}); });
        this.setState({loading: false});
      },
    });
  }

  applyErrors() {
    const errorStyling = {};
    if (!this.state.name) { errorStyling.name = {borderColor: 'red'}; }
    if (!this.state.audience) { errorStyling.audience = 'error'; }
    this.setState({ errorStyling });
  }

  renderColorOptions() {
    return ["#ffb748", "#ff687b", "#b6a9f1", "#4fd4c0", "#42b2ee", "#40beff", "#8da0ab"].map(background => (
      React.createElement('div', {
        className: "color-option",
        style: {...colorOptionStyle, background},
        key: background,
        onClick: () => { this.setState({color: background}); },
      })
    ));
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

  render() {
    return (
      <SweetAlert
        title="Create Campaign"
        customClass="airbo"
        cancelBtnCssClass={`cancel ${this.state.loading ? 'disabled' : ''}`}
        confirmBtnCssClass={`confirm ${this.state.loading ? 'disabled' : ''}`}
        confirmBtnText="Create Campaign"
        showCancel={true}
        onCancel={this.props.onClose}
        onConfirm={this.submitCampaign}
        style={{
          display: 'inherit',
          width: '520px',
        }}
      >
      {
        this.state.loading ?
        <LoadingComponent /> :
        <form className="js-edit-campaign-form">
          {this.state.errorStyling.name &&
            <p style={{float: 'left', color: 'red'}}>Required</p>
          }
          <input
            placeholder="Campaign Name"
            type="text"
            name="campaign-name"
            onKeyUp={(e) => { this.handleFormState('name', e.target.value); }}
            id="campaign-name"
            style={this.state.errorStyling.name || {}}
          />

          {this.state.errorStyling.audience &&
            <p style={{marginRight: '100%', color: 'red'}}>Required</p>
          }
          <Select
            onChange={(val) => { this.handleFormState('audience', val === null ? '' : val.value); }}
            className={`camp-audience-select ${this.state.errorStyling.audience}`}
            placeholder="Select Audience"
            isClearable={true}
            options={this.populationSegments}
            isSearchable={true}
          />

          <label style={{marginTop: '25px'}}>Campaign Color</label>
          <div
            className="campaign-colors"
            style={{
              width: "100%",
              marginBottom: "10%",
            }}
          >
            {this.renderColorOptions()}
          </div>

          <div className="color-picker">
            <input
              type="color"
              name="campaign-color"
              id="campaign_color"
              onChange={(e) => { this.handleFormState('color', e.target.value); }}
              value={this.state.color}
              style={{
                height: "24px",
                width: "10%",
                margin: "0",
                padding: "0",
              }}
            />
          </div>
        </form>
      }
      </SweetAlert>
    );
  }
}

CampaignCreatorComponent.propTypes = {
  onClose: PropTypes.func.isRequired,
};

export default CampaignCreatorComponent;
