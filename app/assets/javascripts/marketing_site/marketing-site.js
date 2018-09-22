var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Base = (function() {
  function triggerDemoRequestModal(e) {
    e.preventDefault();
    swal("Hello world!");
    console.log("Demo request");
  }

  function triggerLoginModal(e) {
    e.preventDefault();
    console.log("Let's login!!");
  }

  function init() {
    $(".js-request-demo").click(triggerDemoRequestModal);
    $(".js-login").click(triggerLoginModal);
  }

  return {
    init: init
  };
})();

$(function() {
  if (Airbo.Utils.nodePresent(".airbo-marketing-site")) {
    Airbo.MarketingSite.Base.init();
  }
});
