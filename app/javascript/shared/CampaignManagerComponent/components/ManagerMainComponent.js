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

const renderCampaignCards = props => (
  props.campaigns.map(campaign => (
    React.createElement('div', {className: 'campaign-card', style: cardStyle, key: campaign.label},
      React.createElement('span', {style: {...colorStyle, backgroundColor: campaign.color}}),
      React.createElement('span', {style: textStyle}, campaign.label),
      React.createElement('span', {className: 'circle-button', style: circleButtonStyle, onClick: () => { props.deleteCampaign(campaign.value); }},
        React.createElement('i', {className: `fa fa-trash-o`, style: iconStyle})
      ),
      React.createElement('span', {className: 'circle-button', style: circleButtonStyle, onClick: () => { props.editCampaign(campaign); }},
        React.createElement('i', {className: `fa fa-pencil`, style: iconStyle})
      ),
    )
  ))
);

const ManagerMainComponent = props => (
  <div>
    <div className="manage-campaign-card-container">
      {renderCampaignCards(props)}
    </div>
    {props.errorMsg &&
      <div
      style={{
        display: 'block',
        backgroundColor: 'rgb(241, 241, 241)',
        marginLeft: '-17px',
        marginRight: '-17px',
        marginTop: '20px',
        overflow: 'hidden',
        padding: '10px',
        maxHeight: '100px',
        transition: 'padding 0.25s ease 0s, max-height 0.25s ease 0s',
        color: 'rgb(121, 121, 121)',
        fontSize: '16px',
        textAlign: 'center',
        fontWeight: '300',
      }}
      >
        <div
          style={{
            display: 'inline-block',
            width: '24px',
            height: '24px',
            borderRadius: '50%',
            backgroundColor: 'rgb(234, 125, 125)',
            color: 'white',
            lineHeight: '24px',
            textAlign: 'center',
            marginRight: '5px',
          }}
        >!</div>
        {props.errorMsg}
      </div>
    }
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
  editCampaign: PropTypes.func.isRequired,
  errorMsg: PropTypes.string,
};

export default ManagerMainComponent;
