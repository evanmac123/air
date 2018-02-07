var Airbo = window.Airbo || {};

Airbo.ExploreOnboarding = (function() {
  var currentUserData;

  function init() {
    currentUserData = $("body").data("currentUser");
    var $carousel = $(".flickity-explore-oboarding-carousel");

    $carousel.flickity({
      imagesLoaded: true,
      percentPosition: false,
      contain: true,
      pageDots: false,
      prevNextButtons: false
    });

    $("#exploreOnboardingModal").bind("opened", function() {
      $carousel.fadeIn().flickity("resize");
    });

    bindNextOnboardingSlide();
    bindCloseOnboarding();

    $("#exploreOnboardingModal").foundation("reveal", "open");
  }

  function bindNextOnboardingSlide() {
    $(".next-onboarding-slide").on("click", function(e) {
      e.preventDefault();
      pingSlideComplete("next_slide", $(this));
      $(".flickity-explore-oboarding-carousel").flickity("next");
    });
  }

  function bindCloseOnboarding() {
    $(".close-onboarding").on("click", function(e) {
      e.preventDefault();
      pingSlideComplete("complete", $(this));
      $("#exploreOnboardingModal").foundation("reveal", "close");
    });
  }

  function pingSlideComplete(action, button) {
    var properties = $.extend(
      { action: action, slide: button.data("slide") },
      currentUserData
    );

    Airbo.Utils.ping("Explore page - Onboarding", properties);
  }

  return {
    init: init
  };
})();

$(function() {
  if ($(".flickity-explore-oboarding-carousel").length > 0) {
    Airbo.ExploreOnboarding.init();
  }
});
