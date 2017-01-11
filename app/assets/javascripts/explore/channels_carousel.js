var Airbo = window.Airbo || {};

Airbo.ChannelsCarousel = (function(){
  function init() {
    var $carousel = $('.flickity-channels-carousel');

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
      if (slug) {
        var name = $(cellElement).data("name");
        var currentUserData = $("body").data("currentUser");

        var properties = $.extend({ action: "Clicked Channel", channel: name }, currentUserData);

        Airbo.Utils.ping("Explore page - Interaction", properties);

        if (slug === "explore") {
          window.location = "/explore";
        } else {
          window.location = "/explore/channels/" + slug;
        }
      }
    });
  }

  return {
    init: init
  };

}());

$(function(){
  if ($(".flickity-channels-carousel").length > 0) {
    Airbo.ChannelsCarousel.init();
  }
});
