var Airbo = window.Airbo || {};

Airbo.ExploreOnboarding = (function(){
  var currentUserData
    , flkty
    , carousel
    , tileModal= Airbo.Utils.StandardModal()
    , onboardingModalSelect = '#exploreOnboardingModal'
    , onboardingModal
  ;

  function init() {
    currentUserData = $("body").data("currentUser");
    onboardingModal = $('#exploreOnboardingModal');
    initCarousel();

    onboardingModal.bind('opened', function() {
      carousel.fadeIn().flickity('resize');
    });

    openOnboardingModal()
    initOnboardingNavListener();
  }

  function openOnboardingModal(){
    onboardingModal.foundation('reveal', 'open');
  }

  function initCarousel(){
    carousel = $('.flickity-explore-oboarding-carousel');
    carousel.flickity({
      imagesLoaded: true,
      percentPosition: false,
      contain: true,
      pageDots: false,
      prevNextButtons: false
    });

    flkty = carousel.data("flickity");

    bindNextOnboardingSlide();
    bindCloseOnboarding();

  }

  function initTileModal() {
   tileModal.init({
      modalId: "explore_tile_preview",
      modalClass: "tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show bg-user-side",
      useAjaxModal: true,
      closeSticky: true
    });
  }

  function getTileConent(){
   $.ajax({
      type: "GET",
      dataType: "html",
      url: link,
      data: { partial_only: true, next_tile: next, prev_tile: prev },
      success: function(data, status, xhr){
        tilePreview.init();
        tilePreview.open(data);
        tilePreview.positionArrows();
      },

      error: function(jqXHR, textStatus, error){
        console.log(error);
      }
    });
  }

  function initOnboardingNavListener(){
    carousel.on( 'select.flickity', function() {
      console.log( 'Flickity select ' + flkty.selectedIndex )
    })
  }

  function bindNextOnboardingSlide() {
    $(".next-onboarding-slide").on("click", function(e) {
      e.preventDefault();
      pingSlideComplete("next_slide", $(this));
      $('.flickity-explore-oboarding-carousel').flickity('next');
    });
  }

  function bindCloseOnboarding() {
    $(".close-onboarding").on("click", function(e) {
      e.preventDefault();
      pingSlideComplete("complete", $(this));
      $('#exploreOnboardingModal').foundation('reveal', 'close');
    });
  }

  function pingSlideComplete(action, button) {
    var properties = $.extend({ action: action, slide: button.data("slide") }, currentUserData);

    Airbo.Utils.ping("Explore page - Onboarding", properties);
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
