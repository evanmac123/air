//Disclaimer: This code was from a contractor (with slight restructuring). #gitblamelies.

var Airbo = window.Airbo || {};
Airbo.MarketingSite = Airbo.MarketingSite || {};

Airbo.MarketingSite.Base = (function() {
  function initMarketingSiteHighlightsCarousels() {
    $(".highlights-carousel").flickity({
      groupCells: true,
      wrapAround: true,
      cellAlign: "left",
      resize: true
    });
  }

  function init() {
    initMarketingSiteHighlightsCarousels();
    $(".airbo-marketing-site").foundation();
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
