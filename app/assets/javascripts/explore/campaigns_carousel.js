var Airbo = window.Airbo || {};

Airbo.CampaignsCarousel = (function(){
  function init() {
    var $carousel = $('.flickity-campaigns-carousel');
    var $campaign_sel = $('.campaign');

    $carousel.flickity({
      cellAlign: 'left',
      contain: true,
      groupCells: true,
      wrapAround: true,
      pageDots: false,
      draggable: false,
    });

    $campaign_sel.on( 'click', function( event ) {
      var self = $(this).parents('.carousel-cell');
      var slug = $(self).data("slug");
      var name = $(self).data("name");
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
