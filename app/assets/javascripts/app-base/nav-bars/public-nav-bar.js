var Airbo = window.Airbo || {};

Airbo.PublicNavBar = (function() {
  function init() {
    initMenu();
    initPings();
  }

  function initMenu() {
    $("#menuButton").on("click", function(e) {
      e.preventDefault();
      $(this).toggleClass("is-active");
    });
  }

  function initPings() {
    $(".js-public-nav-bar-cta").on("click", function(e) {
      e.preventDefault();
      Airbo.Utils.ping("Marketing Site Action", {
        action: "CTA Clicked",
        cta: $(this).data("cta"),
        copy: $(this).text(),
        color: $(this).css("color")
      });

      window.location = $(this).data("path");
    });
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".js-public-nav-bar")) {
    Airbo.PublicNavBar.init();
  }
});
