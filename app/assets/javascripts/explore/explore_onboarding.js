var Airbo = window.Airbo || {};

Airbo.ExploreOnboarding = (function(){
  function init() {
    var $carousel = $('.flickity-explore-oboarding-carousel');

    $carousel.flickity({
      imagesLoaded: true,
      percentPosition: false,
      contain: true,
      pageDots: false
    });


    $('#exploreOnboardingModal').bind('opened', function() {
      $carousel.fadeIn().flickity('resize');
    });

    bindNextOnboardingSlide();
    bindCloseOnboarding();

    $('#exploreOnboardingModal').foundation('reveal', 'open');
  }

  function bindNextOnboardingSlide() {
    $(".next-onboarding-slide").on("click", function(e) {
      e.preventDefault();
      $('.flickity-explore-oboarding-carousel').flickity('next');
    });
  }

  function bindCloseOnboarding() {
    $(".close-onboarding").on("click", function(e) {
      e.preventDefault();
      $('#exploreOnboardingModal').foundation('reveal', 'close');
    });
  }

  return {
    init: init
  };

}());

$(function(){
  if ($(".flickity-explore-oboarding-carousel").length > 0) {
    Airbo.ExploreOnboarding.init();
  }
});
