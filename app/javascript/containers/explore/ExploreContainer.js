import React, { Component } from "react";
import CampaignsComponent from "./components/CampaignsComponent";
import LoadingComponent from "../../shared/LoadingComponent";

class Explore extends Component {
  constructor(props) {
    super(props);
    this.state = {
      campaignFeature: "",
      loading: true,
      campaigns: {},
    };
  }

  componentDidMount() {
    fetch('/api/v1/campaigns')
      .then((responseText) => responseText.json())
      .then((response) => {
        this.setState({
          campaigns: response,
          loading: false,
        });
      });
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
        {
          this.state.loading ?
          <LoadingComponent /> :
          <CampaignsComponent
            {...this.state}
            campaignRedirect={this.campaignRedirect}
          />
        }
      </div>
    );
  }
}

export default Explore;
