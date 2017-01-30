var Airbo = window.Airbo || {};

Airbo.OrganizationsCarousel = (function(){
  function init() {
    var $carousel = $('.flickity-organizations-carousel');
    var $organization_sel = $('.organization');

    $carousel.flickity({
      cellAlign: 'left',
      contain: true,
      groupCells: true,
      wrapAround: true,
      pageDots: false,
      draggable: true,
    });

    $carousel.on( 'staticClick.flickity', function( event, pointer, cellElement, cellIndex ) {
      var slug = $(cellElement).data("slug");
      if (slug) {
        var name = $(cellElement).data("name");
        var currentUserData = $("body").data("currentUser");

        var properties = $.extend({ action: "Clicked Organization", organization: name }, currentUserData);

        Airbo.Utils.ping("Explore page - Interaction", properties);

        window.location = "/explore/organizations/" + slug;
      }
    });
  }

  return {
    init: init
  };

}());

$(function(){
  if ($(".flickity-organizations-carousel").length > 0) {
    Airbo.OrganizationsCarousel.init();
  }
});
