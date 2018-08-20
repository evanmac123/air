import React, { Component } from "react";
import PropTypes from "prop-types";
import Select from 'react-select';

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
      color: '',
    };
  }

  render() {
    return (
      <form className="js-edit-campaign-form">
        <input
          placeholder="Campaign Name"
          type="text"
          name="campaign-name"
          onKeyUp={() => { debugger }}
          id="campaign-name"
        />

        <Select
          onChange={(val, act) => { debugger }}
          className="camp-audience-select"
          placeholder="Audience"
          isClearable={true}
          options={[{label: 'All Users', value: 'all'}, {label: 'Health', value: '4'}]}
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
          <div className="color-option" style={{...colorOptionStyle, background: "#ffb748"}}>
          </div>
          <div className="color-option" style={{...colorOptionStyle, background: "#ff687b"}}>
          </div>
          <div className="color-option" style={{...colorOptionStyle, background: "#b6a9f1"}}>
          </div>
          <div className="color-option" style={{...colorOptionStyle, background: "#4fd4c0"}}>
          </div>
          <div className="color-option" style={{...colorOptionStyle, background: "#42b2ee"}}>
          </div>
          <div className="color-option" style={{...colorOptionStyle, background: "#40beff"}}>
          </div>
          <div className="color-option" style={{...colorOptionStyle, background: "#8da0ab"}}>
          </div>
        </div>

        <div className="color-picker">
          <input
            type="color"
            name="campaign[color]"
            id="campaign_color"
            value="#ffb748"
            className="js-campaign-color"
            style={{
              height: "24px",
              width: "10%",
              margin: "0",
              padding: "0",
            }}
          />
        </div>
      </form>
    );
  }
}

export default CampaignCreatorComponent;
