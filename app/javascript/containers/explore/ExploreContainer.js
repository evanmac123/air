import React, { Component } from "react";
import PropTypes from "prop-types";
import * as $ from "jquery";

import CampaignsComponent from "./components/CampaignsComponent";
import LoadingComponent from "../../shared/LoadingComponent";
import { Fetcher } from "../../lib/helpers";

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
    this.navbarRedirect = this.navbarRedirect.bind(this);
    this.copyTile = this.copyTile.bind(this);
    this.copyAllTiles = this.copyAllTiles.bind(this);
  }

  componentDidMount() {
    Fetcher.get("/api/v1/campaigns", response => {
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
          description: resp.description,
          ongoing: resp.ongoing,
          copyText: "Copy Campaign",
        });
        initCampaignState[`campaignTiles${resp.id}`] = resp.tiles;
      });
      this.setState(initCampaignState);
    });
  }

  navbarRedirect(e) {
    e.preventDefault();
    this.setState({
      selectedCampaign: {},
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
    Fetcher.get(`/api/v1/campaigns/${campaign.id}`, response => {
      const newState = {
        selectedCampaign: campaign,
        loading: false,
      };
      newState[`campaignTiles${campaign.id}`] = response;
      this.setState(newState);
    });
  }

  copyToBoard(copyPath, $tile, successCb) {
    Fetcher.xmlHttpRequest(copyPath, {
      success: () => { successCb($tile); },
      err: err => { console.error(err, "Something went wrong"); },
    });
  }

  copyTile(data) {
    const $tile = $(`#${data.id}`);
    $tile.text("Copying...");
    this.copyToBoard(data.copyPath, $tile, self => {
      self.text("Copied");
      window.Airbo.ExploreKpis.copyTilePing(self, "thumbnail");
    });
  }

  copyAllTiles(e) {
    e.preventDefault();
    const $target = $(e.target);
    window.Airbo.ExploreKpis.copyAllTilesPing($target);
    this.setState({ selectedCampaign: {...this.state.selectedCampaign, copyText: "Copying..."} });
    this.state[`campaignTiles${this.state.selectedCampaign.id}`].forEach(this.copyTile);
    this.setState({ selectedCampaign: {...this.state.selectedCampaign, copyText: "Campaign Copied"} });
    $target.addClass("disabled green");
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
            navbarRedirect={this.navbarRedirect}
            copyTile={this.copyTile}
            copyAllTiles={this.copyAllTiles}
            user={this.props.user}
          />
        }
      </div>
    );
  }
}

Explore.propTypes = {
  user: PropTypes.object,
};


export default Explore;
