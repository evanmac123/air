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

  assignRouteData(route, re, cb) {
    if (this.routesList[route].variables.length) {
      let counter = 1;
      this.routeData = this.routesList[route].variables.reduce((result, variable) => {
        result[variable] = re[counter]; // eslint-disable-line
        counter++;
        return result;
      }, {});
      if (cb) { cb(); }
    } else if (cb) {
      cb();
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
        break;
      }
    }
  };

  updateCurrentRoute() {
    this.assignCurrentRoute(() => {
      this.reactComponent.setState({
        currentRoute: this.currentRoute,
        routeData: this.routeData,
      });
      window.scrollTo(0,0);
    });
  }
}

export default AiRouter;
