var Airbo = window.Airbo || {};

Airbo.ExploreOnboarding = (function(){
  var currentUserData
    , flkty
    , carousel
    , tileModal= Airbo.Utils.StandardModal()
    , onboardingModal
    , tileContent
    , self;
  ;

  function init() {
    self = this;
    currentUserData = $("body").data("currentUser");
    onboardingModal = $('#exploreOnboardingModal');
    initTileModal()
    getDemoTile();

  }

  function initOnboarding(){
    initCarousel();
    onboardingModal.bind('opened', function() {
      carousel.fadeIn().flickity('resize');
    });
    openOnboardingModal()
  }

  function initOnboardingNavListener(){
    carousel.on( 'select.flickity', function() {
      if(flkty.selectedIndex === 2){

        showTile();;
      }
    })
  }

  function showTile(){
    tileModal.open();
    Airbo.StickyMenu.init(tileModal);
    Airbo.ImageLoadingPlaceholder.init();
    Airbo.TileAnswers.init()
  }

  function initTileModal() {
    tileModal.init({
      modalId: "onboarding_tile_preview",
      modalClass: "tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show in-onboarding bg-user-side",
      useAjaxModal: true,
      closeSticky: true,
      onClosedEvent: function(){
        tileModal= undefined;
        onboardingModal.foundation('reveal', 'open');
      }
    });
  }



  function getDemoTile(){
    var xhr = getTileConent();
    xhr.then(function(data){
      tileModal.setContent(data);
      initOnboarding();
      initOnboardingNavListener();
    });
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



  function getTileConent(){
    var tile = $(".tile_thumb_link_explore").first();
    return $.ajax({
      type: "GET",
      dataType: "html",
      url: tile.attr("href"),
      data: { partial_only: true},
    });
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
      closeOnboarding();
    });
  }

  function closeOnboarding(){
    $('#exploreOnboardingModal').foundation('reveal', 'close');
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
