var Airbo = window.Airbo || {};

Airbo.CampaignsCarousel = (function() {
  function init() {
    var $carousel = $(".flickity-campaigns-carousel");
    var flickityParams = {
      cellAlign: "left",
      contain: true,
      groupCells: true,
      pageDots: false
    };

    if ($carousel.children().length > 6) {
      flickityParams.wrapAround = true;
    }

    $carousel.fadeIn();
    $carousel.flickity(flickityParams);

    $carousel.on("staticClick.flickity", function(event, pointer, cellElement) {
      var path = $(cellElement).data("path");
      var slug = $(cellElement).data("slug");
      var name = $(cellElement).data("name");

      if (slug) {
        Airbo.Utils.ping("Explore page - Interaction", {
          action: "Clicked Campaign",
          campaign: name
        });

        window.location = path;
      }
    });
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".flickity-campaigns-carousel").length > 0) {
    Airbo.CampaignsCarousel.init();
  }
});
