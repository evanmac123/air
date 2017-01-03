var Airbo = window.Airbo || {};

Airbo.CampaignsCarousel = (function(){
  function init() {
    var $carousel = $('.flickity-campaigns-carousel');

    $carousel.fadeIn();
    $carousel.flickity({
      cellAlign: 'left',
      contain: true,
      groupCells: true,
      wrapAround: true,
      pageDots: false,
    });

    $carousel.on( 'staticClick.flickity', function( event, pointer, cellElement, cellIndex ) {
      var slug = $(cellElement).data("slug");
      var name = $(cellElement).data("name");
      var currentUserData = $("body").data("currentUser");

      var properties = $.extend({ action: "Clicked Campaign", campaign: name }, currentUserData);

      Airbo.Utils.ping("Explore page - Interaction", properties);

      window.location = "/explore/campaigns/" + slug;
    });
  }

  return {
    init: init
  };

}());

$(function(){
  if ($(".flickity-campaigns-carousel").length > 0) {
    Airbo.CampaignsCarousel.init();
  }
});
