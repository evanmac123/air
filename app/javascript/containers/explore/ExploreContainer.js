import React, { Component } from "react";
import CampaignsComponent from './components/CampaignsComponent';

class Explore extends Component {
  constructor(props) {
    super(props);
    this.state = {
      campaignFeature: '',
      loading: false,
    };
  }

  render() {
    return (
      <div className="explore-container">
        <CampaignsComponent
          {...this.props}
        />
      </div>
    );
  }
}

export default Explore;
