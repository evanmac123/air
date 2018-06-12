import React, { Component } from "react";
import CampaignsComponent from "./components/CampaignsComponent";

class Explore extends Component {
  constructor(props) {
    super(props);
    this.state = {
      campaignFeature: "",
      loading: false,
    };
  }

  campaignRedirect(campaign) {
    window.Airbo.Utils.ping("Explore page - Interaction", {
      action: "Clicked Campaign",
      campaign: campaign.name,
      campaignId: campaign.id,
    });
    window.location = campaign.path;
  };

  render() {
    return (
      <div className="explore-container">
        <CampaignsComponent
          {...this.props}
          campaignRedirect={this.campaignRedirect}
        />
      </div>
    );
  }
}

export default Explore;
