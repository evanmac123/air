var Airbo = window.Airbo || {};

Airbo.ExploreIntro = (function(){
  var modalObj = Airbo.Utils.StandardModal();
  function initEvents() {
    $(".slick_next").click(function(e) {
      e.preventDefault();
      $(".explore_intro").slick('slickNext');
    })
  }
  function initModalObj() {
    modalObj.init({
      modalId: "explore_intro_modal",
      closeSel: ".close_explore_intro",
      onOpenedEvent: function() {
        // $(document).foundation();
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