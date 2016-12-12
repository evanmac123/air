var Airbo = window.Airbo || {};

Airbo.ChannelsCarousel = (function(){
  function init() {
    var $carousel = $('.flickity-channels-carousel');

    $carousel.flickity({
      cellAlign: 'center',
      contain: true,
      groupCells: true,
    });

    $carousel.on( 'staticClick.flickity', function( event, pointer, cellElement, cellIndex ) {
      var id = $(cellElement).data("id");
      window.location = "/client_admin/channels/" + id;
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
