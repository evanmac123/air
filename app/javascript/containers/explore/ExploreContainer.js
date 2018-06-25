import React, { Component } from "react";
import PropTypes from "prop-types";
import * as $ from "jquery";

import CampaignsComponent from "./components/CampaignsComponent";
import LoadingComponent from "../../shared/LoadingComponent";
import { Fetcher, WindowHelper } from "../../lib/helpers";

class Explore extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selectedCampaign: {},
      loading: true,
      scrollLoading: false,
      campaigns: [],
      winWidth: 0,
      winHeight: 0,
    };
    this.campaignRedirect = this.campaignRedirect.bind(this);
    this.getCampaignTiles = this.getCampaignTiles.bind(this);
    this.navbarRedirect = this.navbarRedirect.bind(this);
    this.copyTile = this.copyTile.bind(this);
    this.copyAllTiles = this.copyAllTiles.bind(this);
    this.updateDimensions = this.updateDimensions.bind(this);
    this.getAllCampaigns = this.getAllCampaigns.bind(this);
    this.onScroll = this.onScroll.bind(this);
  }

  componentDidMount() {
    const latestTile = localStorage.getItem('latestTile');
    if (latestTile && latestTile === this.props.ctrl.latestTile) {
      this.setState(JSON.parse(localStorage.getItem('campaign-data')));
    } else {
      this.getAllCampaigns();
    }
    this.updateDimensions();
    window.addEventListener("resize", this.updateDimensions);
    window.addEventListener("scroll", this.onScroll, false);
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.updateDimensions);
    window.removeEventListener("scroll", this.onScroll, false);
  }

  onScroll() {
    const camp = this.state.selectedCampaign;
    const scrollTop = $(document).scrollTop();
    const windowHeight = $(window).height();
    const bodyHeight = $(document).height() - windowHeight;
    const scrollPercentage = (scrollTop / bodyHeight);
    if (!this.state.scrollLoading && (camp && !!this.state[`tilePageLoaded${camp.id}`]) &&
        (scrollPercentage > 0.95)) {
      this.setState({ scrollLoading: true });
      this.getCampaignTiles(this.state.selectedCampaign);
    }
  }

  updateDimensions() {
    const newDimensions = WindowHelper.getDimensions();
    this.setState(newDimensions);
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
      this.getCampaignTiles(campaign, { loading: true });
    } else {
      this.setState({ selectedCampaign: campaign });
    }
  };

  getAllCampaigns() {
    Fetcher.get("/api/v1/campaigns", response => {
      const initCampaignState = {
        campaigns: [],
        loading: false,
      };
      response.forEach(resp => {
        initCampaignState[`tilePageLoaded${resp.id}`] = ( resp.tiles.length < 28 ? 0 : 1 );
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
      localStorage.setItem('campaign-data', JSON.stringify(initCampaignState));
      localStorage.setItem('latestTile', this.props.ctrl.latestTile);
    });
  };

  getCampaignTiles(campaign, opts) {
    const page = this.state[`tilePageLoaded${campaign.id}`] + 1;
    this.setState(opts);
    Fetcher.get(`/api/v1/campaigns/${campaign.id}?page=${page}`, response => {
      const newState = {
        selectedCampaign: campaign,
        loading: false,
        scrollLoading: false,
      };
      newState[`tilePageLoaded${campaign.id}`] = ( response.length < 28 ? 0 : page );
      newState[`campaignTiles${campaign.id}`] = (this.state[`campaignTiles${campaign.id}`] || []).concat(response);
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
            user={this.props.ctrl}
          />
        }
      </div>
    );
  }
}

Explore.propTypes = {
  ctrl: PropTypes.object,
};


export default Explore;
