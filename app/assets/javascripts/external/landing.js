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
  }
  return {
  init: init
}
}());

$(function(){
  if( $(".pages.pages-show.landing").length > 0 ){
    Airbo.Landing.init();
  }
});
