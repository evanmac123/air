import React, { Component } from "react";
import PropTypes from "prop-types";
import * as $ from "jquery";

import CampaignsComponent from "./components/CampaignsComponent";
import LoadingComponent from "../../shared/LoadingComponent";
import CampaignApi from "./CampaignApi";
import { Fetcher, WindowHelper, LocalStorer, InfiniScroller } from "../../lib/helpers";
import { AiRouter } from "../../lib/utils";

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
    this.updateActiveDisplay = this.updateActiveDisplay.bind(this);
    this.populateCampaigns = this.populateCampaigns.bind(this);
    this.getAdditionalTiles = this.getAdditionalTiles.bind(this);
    this.scrollState = new InfiniScroller({
      scrollPercentage: 0.95,
      throttle: 100,
      onScroll: this.getAdditionalTiles,
    });
  }

  componentDidMount() {
    this.populateCampaigns().then(() => this.updateActiveDisplay());
    this.updateDimensions();
    this.scrollState.setOnScroll();
    window.addEventListener("resize", this.updateDimensions);
    window.addEventListener("popstate", this.updateActiveDisplay);

  }

  componentWillUnmount() {
    this.scrollState.removeOnScroll();
    window.removeEventListener("resize", this.updateDimensions);
    window.removeEventListener("popstate", this.updateActiveDisplay);
  }

  updateActiveDisplay() {
    const splitRoute = AiRouter.currentUrl().split("/");
    const campaignId = [...splitRoute].pop();
    if (campaignId === "explore" && splitRoute.length < 3) {
      this.setState({
        selectedCampaign: {},
      });
    } else {
      const camp = CampaignApi.findBy(this.state.campaigns, 'path', `campaigns/${campaignId}`);
      if (camp) {
        this.campaignRedirect(camp, "popstate");
      } else {
        AiRouter.pathNotFound();
      }
    }
  }

  getAdditionalTiles() {
    const camp = this.state.selectedCampaign;
    if (!this.state.scrollLoading && (camp && !!this.state[`tilePageLoaded${camp.id}`])) {
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
    AiRouter.navigation("explore");
    this.setState({
      selectedCampaign: {},
    });
  }

  campaignRedirect(campaign, popstate) {
    window.scrollTo(0,0);
    if (!popstate) {
      window.Airbo.Utils.ping("Explore page - Interaction", {
        action: "Clicked Campaign",
        campaign: campaign.name,
        campaignId: campaign.id,
      });
      AiRouter.navigation(campaign.path, {appendToCurrentUrl: true});
    }
    if (!this.state[`campaignTiles${campaign.id}`]) {
      this.getCampaignTiles(campaign, { loading: true });
    } else {
      this.setState({ selectedCampaign: campaign });
    }
  }

  populateCampaigns() {
    const storage = LocalStorer.getAll(['latestTile', 'currentBoard']);
    return new Promise(resolve => {
      if ((storage.latestTile && storage.latestTile === this.props.ctrl.latestTile) &&
          (!!storage.currentBoard && storage.currentBoard === this.props.ctrl.currentBoard)) {
        this.setState(LocalStorer.get('campaign-data'));
        resolve();
      } else {
        this.getAllCampaigns(resolve);
      }
    });
  }

  getAllCampaigns(callback) {
    CampaignApi.getAll(this.props.ctrl.currentBoard, response => {
      const initCampaignState = {
        campaigns: [],
        loading: false,
      };
      response.forEach(resp => {
        initCampaignState[`tilePageLoaded${resp.id}`] = ( resp.tiles.length < 28 ? 0 : 1 );
        initCampaignState.campaigns.push(CampaignApi.sanitizeCampaignResponse(resp));
        initCampaignState[`campaignTiles${resp.id}`] = resp.tiles;
      });
      this.setState(initCampaignState);
      LocalStorer.setAll({
        'campaign-data': JSON.stringify(initCampaignState),
        'latestTile': this.props.ctrl.latestTile,
        'currentBoard': this.props.ctrl.currentBoard,
      });
      if (callback) { callback(); }
    });
  }

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
    Fetcher.xmlHttpRequest({
      path: copyPath,
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
