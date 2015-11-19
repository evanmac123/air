var Airbo = window.Airbo || {};

Airbo.Landing = (function(){
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
  if( $(".pages.pages-welcome.landing, .pages.pages-asha.landing").length > 0 ){
    Airbo.Landing.init();
  }
});
