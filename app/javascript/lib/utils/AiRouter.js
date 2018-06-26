const sanitizeUrl = url => (url[0] !== "/" ? `/${url}` : url);

const AiRouter = {
  currentUrl: () => window.location.pathname,
  navigation: (url, opts = {}) => {
    const sanitizedUrl = sanitizeUrl(url);
    const stateObj = opts.stateObj || {};
    const title = opts.title || "Airbo";
    const newUrl = (opts.appendToCurrentUrl ? (window.location + sanitizedUrl) : `${sanitizedUrl}`);
    window.history.pushState(stateObj, title, newUrl);
  },
};

export default AiRouter;
