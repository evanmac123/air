import { Fetcher } from "../../lib/helpers";

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

const CampaignApi = {};

CampaignApi.sanitizeCampaignResponse = resp => ({
  id: resp.id,
  name: resp.name,
  thumbnails: parseLandingExploreThumbnails(resp.tiles),
  description: resp.description,
  ongoing: resp.ongoing,
  copyText: "Copy Campaign",
  path: `campaigns/${resp.id}-${resp.name.toLowerCase().replace(/[^A-Za-z0-9 ]/g, '').replace(/\s+/g,"-")}`,
});

CampaignApi.getAll = (currentBoard, respFn) => {
  Fetcher.get(`/api/v1/campaigns?demo=${currentBoard}`, respFn);
};

CampaignApi.findBy = (campaigns, key, value) => {
    for (let i = 0; i < campaigns.length; i++) {
      if (`${campaigns[i][key]}` === value) { return campaigns[i]; }
    }
    return false;
  };

export default CampaignApi;
