import React from "react";
import PropTypes from "prop-types";

const cardStyle = {
  height: '65px',
  marginBottom: '15px',
  padding: '10px',
};

const textStyle = {
  float: 'left',
  margin: '14px 0px 0px 4%',
};

const circleButtonStyle = {
  width: '32px',
  height: '32px',
  border: '1px solid #999999',
  borderRadius: '50%',
  padding: '9px 0 9px 0',
  margin: '6px',
  float: 'right',
};

const iconStyle = {
  marginTop: '-3px',
  fontSize: '1.2rem',
};

const colorStyle = {
  width: '15px',
  height: '15px',
  borderRadius: '50%',
  margin: '14px 0 0 4%',
  float: 'left',
};

const renderCampaignCards = (campaigns, deleteCampaign) => (
  campaigns.map(campaign => (
    React.createElement('div', {className: 'campaign-card', style: cardStyle, key: campaign.label},
      React.createElement('span', {style: {...colorStyle, backgroundColor: campaign.color}}),
      React.createElement('span', {style: textStyle}, campaign.label),
      React.createElement('span', {className: 'circle-button', style: circleButtonStyle, onClick: () => { deleteCampaign(campaign.value); }},
        React.createElement('i', {className: `fa fa-trash-o`, style: iconStyle})
      ),
      React.createElement('span', {className: 'circle-button', style: circleButtonStyle},
        React.createElement('i', {className: `fa fa-pencil`, style: iconStyle})
      ),
    )
  ))
);

const ManagerMainComponent = props => (
  <div>
    <div className="manage-campaign-card-container">
      {renderCampaignCards(props.campaigns, props.deleteCampaign)}
    </div>
  </div>
);

ManagerMainComponent.propTypes = {
  campaigns: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]).isRequired,
    label: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  })).isRequired,
  deleteCampaign: PropTypes.func.isRequired,
};

export default ManagerMainComponent;
