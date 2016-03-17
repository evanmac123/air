var Airbo = window.Airbo || {};

Airbo.StickyHeader = (function(){
  function init() {
    $(window).scroll(function() {
      if ($(window).scrollTop() > 100) {
        $('header').addClass('sticky');
      } else {
        $('header').removeClass('sticky');
      }
    });
    // Mobile Navigation
    $('.mobile-toggle').click(function() {
      $("header").toggleClass('open-nav');
    });
  }
  return {
  init: init
}
}());

$(function(){
  // so specific selectors because we have product page with old header
  if( $("header.sticky_desktop").length > 0 ){
    Airbo.StickyHeader.init();
  }
});
