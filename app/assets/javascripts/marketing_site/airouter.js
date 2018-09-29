var Airbo = window.Airbo || {};
Airbo.AiRouter = Airbo.AiRouter || {};

Airbo.AiRouter = (function() {
  var definedRoutes;

  function clearPageContent() {
    for (var i = 0; i < Object.keys(definedRoutes).length; i++) {
      var el = document.getElementById(Object.keys(definedRoutes)[i]);
      if (el) {
        el.innerHTML = "";
      }
    }
  }

  function renderPage(routeKey, cb) {
    clearPageContent();
    window.scrollTo(0, 0);
    $body = document.getElementById(routeKey);
    try {
      $body.innerHTML = definedRoutes[routeKey].htmlContent || "";
    } catch (e) {
      if (!$body) {
        console.warn(
          "AiRouter could not find HTML source for routeKey `" +
            routeKey +
            "`. Ensure HTML is wrapped with an HTML element containing the class `airoute-" +
            routeKey +
            "`"
        );
      }
    } finally {
      if (cb) {
        cb();
      }
    }
  }

  function getAElement(target) {
    if (target.nodeName === "A") {
      return target;
    }
    return getAElement(target.parentElement);
  }

  function pushState(routeKey, path) {
    var newUrl = window.location.origin + path;
    var stateObj = definedRoutes[routeKey].stateObj || {};
    var title = definedRoutes[routeKey].title || "Airbo";
    window.history.pushState(stateObj, title, newUrl);
  }

  function getRouteKey(classList) {
    for (var i = 0; i <= classList.length; i++) {
      if (i === classList.length) {
        throw new TypeError(
          "Invalid HTML element for AiRouter. Must include HTML class `airoute-<route key>` in class list."
        );
      }
      if (classList[i].split("-")[0] === "airoute") {
        return classList[i].split("-")[1];
      }
    }
  }

  function getRouteKeyFromPath() {
    var routeKeys = Object.keys(definedRoutes);
    var pathname = window.location.pathname;
    for (var i = 0; i <= routeKeys.length; i++) {
      if (i === routeKeys.length) {
        window.location = "/404.html";
      }
      if (definedRoutes[routeKeys[i]].path === pathname) {
        return routeKeys[i];
      }
    }
  }

  function direct_to(e) {
    e.preventDefault();
    var $a = getAElement(e.target);
    var routeKey = getRouteKey($a.classList);
    var properKey = routeKey.charAt(0).toUpperCase() + routeKey.substr(1);
    var path = $a.pathname;
    pushState(routeKey, path);
    renderPage(routeKey, function() {
      if (Airbo[properKey]) {
        Airbo[properKey].init();
      }
    });
  }

  function handleDirectionalState() {
    var currentKey = getRouteKeyFromPath();
    var properKey = currentKey.charAt(0).toUpperCase() + currentKey.substr(1);
    renderPage(currentKey, function() {
      if (Airbo[properKey]) {
        Airbo[properKey].init();
      }
    });
  }

  function defineRoutes(routes) {
    definedRoutes = routes;
    var routesKeys = Object.keys(routes);
    var currentKey = getRouteKeyFromPath();
    var properKey = currentKey.charAt(0).toUpperCase() + currentKey.substr(1);
    for (var i = 0; i < routesKeys.length; i++) {
      $routeContent = document.getElementById(routesKeys[i]);
      if ($routeContent) {
        definedRoutes[routesKeys[i]].htmlContent = $routeContent.innerHTML;
        $routeContent.innerHTML = "";
      } else {
        definedRoutes[routesKeys[i]].htmlContent = "";
      }
      $(document).on("click", "a.airoute-" + routesKeys[i], direct_to);
    }
    renderPage(currentKey, function() {
      if (Airbo[properKey]) {
        Airbo[properKey].init();
      }
      document.getElementById("airoute-yield").style.display = "initial";
    });
    window.addEventListener("popstate", handleDirectionalState);
  }

  return {
    defineRoutes: defineRoutes
  };
})();
