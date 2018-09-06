const sanitizeUrl = url => (url[0] !== "/" ? `/${url}` : url);

const getNewUrl = (sanitizedUrl, opts) => {
  const appendTo = opts.appendTo || window.location;
  if (opts.appendToCurrentUrl || opts.hashRoute) {
    return `${appendTo + (opts.hashRoute ? `#${sanitizedUrl.substring(1)}` : sanitizedUrl)}`;
  }
  return `${sanitizedUrl}`;
};

const AiRouter = {
  currentUrl: () => window.location.pathname,
  href: () => window.location.href,
  splitHref: splitBy => window.location.href.split(splitBy),
  navigation: (url, opts = {}) => {
    const sanitizedUrl = sanitizeUrl(url);
    const stateObj = opts.stateObj || {};
    const title = opts.title || "Airbo";
    const newUrl = getNewUrl(sanitizedUrl, opts);
    window.history.pushState(stateObj, title, newUrl);
  },
  pathNotFound: () => {
    window.location = '/explore/not_found';
  },
};

export default AiRouter;
