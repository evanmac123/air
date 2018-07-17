import React, { Component } from "react";
import PropTypes from "prop-types";
import * as $ from "jquery";

import CampaignsComponent from "./components/CampaignsComponent";
import LoadingComponent from "../../shared/LoadingComponent";
import { Fetcher, WindowHelper } from "../../lib/helpers";
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
    this.getCampaignById = this.getCampaignById.bind(this);
    this.populateCampaigns = this.populateCampaigns.bind(this);
    this.onScroll = this.onScroll.bind(this);
  }

  componentDidMount() {
    this.populateCampaigns().then(() => this.updateActiveDisplay());
    this.updateDimensions();
    window.addEventListener("resize", this.updateDimensions);
    window.addEventListener("scroll", this.onScroll, false);
    window.addEventListener("popstate", this.updateActiveDisplay);
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.updateDimensions);
    window.removeEventListener("scroll", this.onScroll, false);
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
      const camp = this.getCampaignById(campaignId.split("-")[0]);
      if (camp) {
        this.campaignRedirect(camp, "popstate");
      } else {
        AiRouter.navigation("explore");
      }
    }
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
    AiRouter.navigation("explore");
    this.setState({
      selectedCampaign: {},
    });
  }

  campaignRedirect(campaign, popstate) {
    const redirectUrl = `campaigns/${campaign.id}-${campaign.name.toLowerCase().replace(/\s+/g,"-")}`;
    if (!popstate) {
      window.Airbo.Utils.ping("Explore page - Interaction", {
        action: "Clicked Campaign",
        campaign: campaign.name,
        campaignId: campaign.id,
      });
      AiRouter.navigation(redirectUrl, {appendToCurrentUrl: true});
    }
    if (!this.state[`campaignTiles${campaign.id}`]) {
      this.getCampaignTiles(campaign, { loading: true });
    } else {
      this.setState({ selectedCampaign: campaign });
    }
  }

  populateCampaigns() {
    const latestTile = localStorage.getItem('latestTile');
    const currentBoard = localStorage.getItem('currentBoard');
    return new Promise(resolve => {
      if ((latestTile && latestTile === this.props.ctrl.latestTile) &&
          (!!currentBoard && currentBoard === `${this.props.ctrl.currentBoard}`)) {
        this.setState(JSON.parse(localStorage.getItem('campaign-data')));
        resolve();
      } else {
        this.getAllCampaigns(resolve);
        // resolve();
      }
    });
  }

  getAllCampaigns(cb) {
    const parseLandingExploreThumbnails = tiles => {
      const exploreThumbnails = [];
      for (let i = 0; i < tiles.length; i++) {
        if (exploreThumbnails.length === 3) { return exploreThumbnails; }
        if (tiles[i].thumbnailContentType !== "image/gif") {
          exploreThumbnails.push(tiles[i].thumbnail);
        }
      }
      return exploreThumbnails;
    };

    Fetcher.get(`/api/v1/campaigns?demo=${this.props.ctrl.currentBoard}`, response => {
      const initCampaignState = {
        campaigns: [],
        loading: false,
      };
      response.forEach(resp => {
        initCampaignState[`tilePageLoaded${resp.id}`] = ( resp.tiles.length < 28 ? 0 : 1 );
        initCampaignState.campaigns.push({
          id: resp.id,
          name: resp.name,
          thumbnails: parseLandingExploreThumbnails(resp.tiles),
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
      localStorage.setItem('currentBoard', this.props.ctrl.currentBoard);
      if (cb) { cb(); }
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

  getCampaignById(id) {
    for (let i = 0; i < this.state.campaigns.length; i++) {
      if (`${this.state.campaigns[i].id}` === id) { return this.state.campaigns[i]; }
    }
    return false;
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
