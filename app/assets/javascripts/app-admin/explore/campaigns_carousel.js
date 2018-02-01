var Airbo = window.Airbo || {};

Airbo.CampaignsCarousel = (function() {
  function init() {
    var $carousel = $(".flickity-campaigns-carousel");

    $carousel.fadeIn();
    $carousel.flickity({
      cellAlign: "left",
      contain: true,
      groupCells: true,
      // wrapAround: true,
      pageDots: false
    });

    $carousel.on("staticClick.flickity", function(
      event,
      pointer,
      cellElement,
      cellIndex
    ) {
      var path = $(cellElement).data("path");
      var slug = $(cellElement).data("slug");
      if (slug) {
        var name = $(cellElement).data("name");
        var currentUserData = $("body").data("currentUser");

        var properties = $.extend(
          { action: "Clicked Campaign", campaign: name },
          currentUserData
        );

        Airbo.Utils.ping("Explore page - Interaction", properties);

        if (slug === "explore") {
          window.location = "/explore";
        } else {
          window.location = path;
        }
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
