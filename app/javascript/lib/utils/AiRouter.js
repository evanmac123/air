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
)

const generateRouteMatch = re => {
  const reEscape = /[\-\[\]{}()+?.,\\\^$|#\s]/g;
  const reParam = /([:*])(\w+)/g;
  const names = [];
  return re.replace(reEscape, "\\$&").replace(reParam, function(_, mode, name) {
    names.push(name);
    // :param should capture until the next / or EOL, while *splat should
    // capture until the next :param, *splat, or EOL.
    return mode === ":" ? "([^/]*)" : "(.*)";
  });
}

const parseRoutes = routes => (
  routes.reduce((result, route) => {
    result[route] = {
      wildcardEnd: route.split('/')[route.split('/').length - 1] === '*',
      variables: getRouteVariables(route.split('/')),
    }
    return result;
    const splitRoute = route.split('/');

  }, {})
);

const stripWildcard = (givenRoute, currentRoute) => {
  debugger
};

const assignCurrentRoute = (routesList) => {
  const routeNames = Object.keys(routesList);
  for (var i = 0; i < routeNames.length; i++) {
    const route = routeNames[i];
    const url = AiRouter.currentUrl();
    const routeMatcher = new RegExp("^" + generateRouteMatch(route) + "$");
    if (url.match(routeMatcher)) { return route; }
  }
}


class AiRouter {
  constructor(routes, reactComponent) {
    this.routesList = parseRoutes(Object.keys(routes));
    this.reactComponent = reactComponent;
    this.connect = this.connect.bind(this);
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

  updateCurrentRoute() {
    const currentRoute = assignCurrentRoute(this.routesList);
    this.reactComponent.setState({ currentRoute });
    window.scrollTo(0,0);
  }
}

export default AiRouter;
