var Airbo = window.Airbo || {};

Airbo.ExploreIntro = (function(){
  var modalObj = Airbo.Utils.StandardModal()
    , slickIntroSel = ".explore_intro"
    , slickIntro
    , nextBtnSel = ".slick_next"
    , nextBtn
    , modalId = "explore_intro_modal"
    , modalSel = "#" + modalId
    , skipSel = modalSel + " .skip"
    , skipLink
    , navDotsSel = ".slick-dots button"
    , slideName = ["Welcome - New User", "Tile", "Board", "Explore"]
  ;
  function ping(property, option) {
    var properties = {};
    properties[property] = option;
    Airbo.Utils.ping("Explore Onboarding", properties);
  }
  function initEvents() {
    nextBtn.click(function(e) {
      e.preventDefault();
      slickIntro.slick('slickNext');
      ping("Clicked Buttons", "Next");
    });
    skipLink.click(function() {
      ping("Clicked Buttons", "Skip");
    });
    $(navDotsSel).click(function() {
      ping("Clicked Buttons", "Nav buttons");
    });
    slickIntro.on('afterChange', function(event, slick, currentSlide){
      ping("Viewed Slide", slideName[currentSlide]);
    });
  }
  function initModalObj() {
    modalObj.init({
      modalId: modalId,
      closeSel: ".close_explore_intro",
      closeOnBgClick: false,
      onOpenedEvent: function() {
        slickIntro.slick({
          autoplay: false,
          dots: true,
          arrows: false
        });
        ping("Viewed Slide", slideName[0]);
        initEvents();
      }
    });
  }
  function initVars() {
    slickIntro = $(slickIntroSel);
    nextBtn = $(nextBtnSel);
    skipLink = $(skipSel);
  }
  function init() {
    initModalObj();
    modalObj.open();
    initVars();
  }
  return {
    init: init,
    modalSel: modalSel
  }
}());

$(document).ready(function(){
  if( $(Airbo.ExploreIntro.modalSel).length > 0 ) {
    Airbo.ExploreIntro.init();
  }
});