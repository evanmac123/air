import React, { Component } from "react";
import CampaignsComponent from "./components/CampaignsComponent";
import LoadingComponent from "../../shared/LoadingComponent";

class Explore extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedCampaign: {},
      loading: true,
      campaigns: [],
    };
    this.campaignRedirect = this.campaignRedirect.bind(this);
    this.getCampaignTiles = this.getCampaignTiles.bind(this);
  }

  componentDidMount() {
    fetch('/api/v1/campaigns')
      .then((responseText) => responseText.json())
      .then((response) => {
        const initCampaignState = {
          campaigns: [],
          loading: false,
        };
        response.forEach(resp => {
          initCampaignState.campaigns.push({
            id: resp.id,
            name: resp.name,
            thumbnails: resp.thumbnails,
            path: resp.path,
          });
          initCampaignState[`campaignTiles${resp.id}`] = resp.tiles;
        });
        this.setState(initCampaignState);
      });
  }

  campaignRedirect(campaign) {
    window.Airbo.Utils.ping("Explore page - Interaction", {
      action: "Clicked Campaign",
      campaign: campaign.name,
      campaignId: campaign.id,
    });
    if (!this.state[`campaignTiles${campaign.id}`]) {
      this.getCampaignTiles(campaign);
    } else {
      this.setState({ selectedCampaign: campaign });
    }
  };

  getCampaignTiles(campaign) {
    this.setState({ loading: true });
    fetch(`/api/v1/campaigns/${campaign.id}`)
      .then((responseText) => responseText.json())
      .then((response) => {
        const newState = {
          selectedCampaign: campaign,
          loading: false,
        };
        newState[`campaignTiles${campaign.id}`] = response;
        this.setState(newState);
      });
  }

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
