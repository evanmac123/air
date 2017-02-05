var Airbo = window.Airbo || {};

Airbo.OrganizationsCarousel = (function(){
  function init() {
    var $carousel = $('.flickity-organizations-carousel');
    $carousel.fadeIn();
    var $organization_sel = $('.organization');

    $carousel.flickity({
      cellAlign: 'center',
      contain: false,
      groupCells: 4,
      wrapAround: true,
      pageDots: false,
      draggable: true,
    });

    $(".visit-organization-link").on("click", function(e) {
      var name = $(this).data("name");
      var id = $(this).data("id");
      var currentUserData = $("body").data("currentUser");

      var properties = $.extend({ action: "Clicked Organization", organization: name, organization_id: id}, currentUserData);

      Airbo.Utils.ping("Explore page - Interaction", properties);
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
