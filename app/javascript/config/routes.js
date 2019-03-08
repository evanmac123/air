import Explore from "../containers/explore";
import ClientAdminTiles from "../containers/clientAdminTiles";
import TileCarousel from "../containers/tileCarousel";
import ActivityBoard from "../containers/activityBoard";

export default {
  '/explore': Explore,
  '/explore/campaigns/:campaign': Explore,
  '/client_admin/tiles': ClientAdminTiles,
  '/tiles': TileCarousel,
  '/ard/:public_slug/tiles': TileCarousel,
  '/activity': ActivityBoard,
  '/ard/:public_slug/activity': ActivityBoard,
  '/acts': ActivityBoard,
};
