import React from "react";
import PropTypes from "prop-types";
import Select from 'react-select';

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

const renderColorOptions = setColorSelection => ["#ffb748", "#ff687b", "#b6a9f1", "#4fd4c0", "#42b2ee", "#40beff", "#8da0ab"].map(background => (
  React.createElement('div', {
    className: "color-option",
    style: {...colorOptionStyle, background},
    key: background,
    onClick: () => { setColorSelection({color: background}); },
  })
));

const CampaignFormComponent = props => (
    <form className="js-edit-campaign-form">
      {props.errorStyling.name &&
        <p style={{float: 'left', color: 'red'}}>Required</p>
      }
      <input
        placeholder="Campaign Name"
        type="text"
        name="campaign-name"
        value={props.name}
        onChange={(e) => { props.handleFormState('name', e.target.value); }}
        id="campaign-name"
        style={props.errorStyling.name || {}}
      />

      {props.errorStyling.audience &&
        <p style={{marginRight: '100%', color: 'red'}}>Required</p>
      }
      <Select
        onChange={(val) => { props.handleFormState('audience', val); }}
        className={`camp-audience-select ${props.errorStyling.audience}`}
        value={props.audience}
        placeholder="Select Audience"
        isClearable={true}
        options={props.populationSegments}
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
        {renderColorOptions(props.setColorSelection)}
      </div>

      <div className="color-picker">
        <input
          type="color"
          name="campaign-color"
          id="campaign_color"
          onChange={(e) => { props.handleFormState('color', e.target.value); }}
          value={props.color}
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

CampaignFormComponent.propTypes = {
  errorStyling: PropTypes.shape({
    name: PropTypes.object,
    audience: PropTypes.string,
  }).isRequired,
  handleFormState: PropTypes.func,
  populationSegments: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]).isRequired,
    label: PropTypes.string.isRequired,
  })),
  setColorSelection: PropTypes.func.isRequired,
  color: PropTypes.string.isRequired,
  name: PropTypes.string,
  audience: PropTypes.shape({
    value: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]).isRequired,
    label: PropTypes.string.isRequired,
  }),
};

export default CampaignFormComponent;