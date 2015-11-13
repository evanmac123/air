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
        // if ($('.main_h').hasClass('open-nav')) {
        //     $('.main_h').removeClass('open-nav');
        // } else {
        //     $('.main_h').addClass('open-nav');
        // }
    });

    // $('.main_h li a').click(function() {
    //     if ($('.main_h').hasClass('open-nav')) {
    //         $('.navigation').removeClass('open-nav');
    //         $('.main_h').removeClass('open-nav');
    //     }
    // });

    // navigation scroll lijepo radi materem
    // $('nav a').click(function(event) {
    //     var id = $(this).attr("href");
    //     var offset = 70;
    //     var target = $(id).offset().top - offset;
    //     $('html, body').animate({
    //         scrollTop: target
    //     }, 500);
    //     event.preventDefault();
    // });
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
