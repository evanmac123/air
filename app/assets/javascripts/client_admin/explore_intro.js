var Airbo = window.Airbo || {};

Airbo.ExploreIntro = (function(){
  var modalObj = Airbo.Utils.StandardModal();
  function ping(property, option) {
    var properties = {};
    properties[property] = option;
    Airbo.Utils.ping("Explore Onboarding", properties);
  }
  function initEvents() {
    $(".slick_next").click(function(e) {
      e.preventDefault();
      $(".explore_intro").slick('slickNext');
      ping("Clicked Buttons", "Next");
    })
  }
  function initModalObj() {
    modalObj.init({
      modalId: "explore_intro_modal",
      closeSel: ".close_explore_intro",
      onOpenedEvent: function() {
        $(".explore_intro").slick({
          autoplay: false,
          dots: true,
          arrows: false
        });
      }
    });
  }
  function init() {
    initModalObj();
    modalObj.open();
    initEvents();
  }
  return {
    init: init
  }
}());

$(document).ready(function(){
  if( $("#explore_intro_modal").length > 0 ) {
    Airbo.ExploreIntro.init();
  }
});