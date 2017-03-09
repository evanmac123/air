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
    initOnboarding();
  }


  function initOnboarding(){
    initCarousel();
    onboardingModal.bind('opened', function() {
      carousel.fadeIn().flickity('resize');
    });
    openOnboardingModal()
  }

  function openOnboardingModal(){
    onboardingModal.foundation('reveal', 'open');
  }

  function bindCorrectTileAnswerClick(){
    $('.right_multiple_choice_answer').on("click", function(event) {
      event.preventDefault();
      setTimeout(function(){

        $('html, body').animate({ scrollTop: $("#exploreOnboardingModal").offset().top }, 550);
        $('body').on('click', '.clicked_right_answer', function(event) {
          $('.flickity-explore-oboarding-carousel').flickity('next');
        });

        $('.flickity-explore-oboarding-carousel').flickity('next');
      }, 1000);
    });
  }

  function initCarousel(){
    carousel = $('.flickity-explore-oboarding-carousel');
    carousel.flickity({
      imagesLoaded: true,
      percentPosition: false,
      contain: true,
      pageDots: false,
      prevNextButtons: false,
      adaptiveHeight: true,
    });

    flkty = carousel.data("flickity");
    initTileNavigationListener();
    bindNextOnboardingSlide();
    bindCloseOnboarding();
  }

  function initTileNavigationListener(){
    carousel.on( 'select.flickity', function() {
      var index = flkty.selectedIndex;
      if(index == 2){
        Airbo.ImageLoadingPlaceholder.init();
        Airbo.TileAnswers.init();
        bindCorrectTileAnswerClick();
      }

      if(index == 3){
        $(".icon--order-success").show();
      }
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
