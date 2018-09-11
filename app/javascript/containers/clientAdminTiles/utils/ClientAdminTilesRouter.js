import constants from './constants';
import { AiRouter } from "../../../lib/utils";

const ClientAdminTilesRouter = {};

ClientAdminTilesRouter.to = statusNav => {
  AiRouter.navigation(`tab-${statusNav}`, {
    hashRoute: true,
    appendTo: '/client_admin/tiles',
  });
};

ClientAdminTilesRouter.getRoute = () => {
  try {
    const routeStatus = AiRouter.splitHref('#')[1].split('-')[1];
    return Object.keys(constants.TILE_STATUS).indexOf(routeStatus) > -1 ? routeStatus : 'plan';
  } catch (e) {
    return 'plan';
  }
};

export default ClientAdminTilesRouter;
