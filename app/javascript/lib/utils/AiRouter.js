import { bodyClassByRoute } from '../../shared/constants';

const sanitizeUrl = url => (url[0] !== "/" ? `/${url}` : url);

const getNewUrl = (sanitizedUrl, opts) => {
  const appendTo = opts.appendTo || window.location;
  if (opts.appendToCurrentUrl || opts.hashRoute) {
    return `${appendTo + (opts.hashRoute ? `#${sanitizedUrl.substring(1)}` : sanitizedUrl)}`;
  }
  return `${sanitizedUrl}`;
};

const getRouteVariables = route => (
  route.reduce((result, sect) => {
    if (sect.charAt(0) === ':') { result.push(sect.split(':')[1]); }
    return result;
  }, [])
);

const generateRouteMatch = re => {
  const reEscape = /[\-\[\]{}()+?.,\\\^$|#\s]/g; // eslint-disable-line
  const reParam = /([:*])(\w+)/g;
  const names = [];
  return re.replace(reEscape, "\\$&").replace(reParam, (_, mode, name) => {
    names.push(name);
    // :param should capture until the next / or EOL, while *splat should
    // capture until the next :param, *splat, or EOL.
    return mode === ":" ? "([^/]*)" : "(.*)";
  });
};

const parseRoutes = routes => (
  routes.reduce((result, route) => {
    /* eslint-disable no-param-reassign */
    result[route] = {
      wildcardEnd: route.split('/')[route.split('/').length - 1] === '*',
      variables: getRouteVariables(route.split('/')),
    };
    /* eslint-enable */
    return result;
  }, {})
);

class AiRouter {
  constructor(routes, reactComponent) {
    this.routesList = parseRoutes(Object.keys(routes));
    this.currentRoute = '';
    this.routeData = {};
    this.reactComponent = reactComponent;
    this.connect = this.connect.bind(this);
    this.assignCurrentRoute = this.assignCurrentRoute.bind(this);
    this.updateCurrentRoute = this.updateCurrentRoute.bind(this);
    this.navigation = this.navigation.bind(this);
  }

  static currentUrl() {
    return window.location.pathname;
  }

  static href() {
    return window.location.href;
  }

  static splitHref(splitBy) {
    return window.location.href.split(splitBy);
  }

  static navigation(url, opts = {}) {
    const sanitizedUrl = sanitizeUrl(url);
    const stateObj = opts.stateObj || {};
    const title = opts.title || "Airbo";
    const newUrl = getNewUrl(sanitizedUrl, opts);
    window.scrollTo(0,0);
    window.history.pushState(stateObj, title, newUrl);
  }

  static pathNotFound() {
    window.location = '/explore/not_found';
  }

  connect() {
    this.updateCurrentRoute();
    window.addEventListener("popstate", this.updateCurrentRoute);
  }

  disconnect() {
    window.removeEventListener("popstate", this.updateCurrentRoute);
  }

  setBodyClass() {
    const body = document.getElementsByTagName("BODY")[0];
    const classByRoute = bodyClassByRoute[this.currentRoute];
    body.className = "";
    classByRoute.split(' ').forEach(klass => {
      body.classList.add(klass);
    });
  };

  assignRouteData(route, re) {
    if (this.routesList[route].variables.length) {
      let counter = 1;
      this.routeData = this.routesList[route].variables.reduce((result, variable) => {
        result[variable] = re[counter]; // eslint-disable-line
        counter++;
        return result;
      }, {});
    }
    if (window.location.search) {
      window.location.search.split('?')[1].split('&').forEach(rawParam => {
        this.routeData[rawParam.split('=')[0]] = rawParam.split('=')[1]; // eslint-disable-line
      });
    }
  }

  assignCurrentRoute(cb) {
    const routeNames = Object.keys(this.routesList);
    for (let i = 0; i < routeNames.length; i++) {
      const route = routeNames[i];
      const url = AiRouter.currentUrl();
      const routeMatcher = new RegExp(`^${generateRouteMatch(route)}$`);
      if (url.match(routeMatcher)) {
        this.currentRoute = route;
        this.assignRouteData(route, url.match(routeMatcher), cb);
        if (cb) { cb(); }
        break;
      }
    }
  };

  updateCurrentRoute() {
    this.assignCurrentRoute(() => {
      const { originId } = this.reactComponent.state;
      this.reactComponent.setState({
        currentRoute: this.currentRoute,
        routeData: this.routeData,
        originId: (this.currentRoute !== '/tiles' && this.currentRoute !== '/explore/campaigns/:campaign') ? null : originId,
      });
      this.setBodyClass();
      window.scrollTo(0,0);
    });
  }

  navigation(url, opts = {}) {
    const sanitizedUrl = sanitizeUrl(url);
    const stateObj = opts.stateObj || {};
    const title = opts.title || "Airbo";
    const newUrl = getNewUrl(sanitizedUrl, opts);
    window.scrollTo(0,0);
    window.history.pushState(stateObj, title, newUrl);
    this.updateCurrentRoute();
  }
}

export default AiRouter;
