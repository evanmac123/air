var Airbo = window.Airbo || {};

Airbo.PublicBoardManager = (function(){

   function setupStickyHeaders(){
    $(window).scroll(function() {
      if ($(window).scrollTop() > $(".user_container").position().top) {
        $('.main_h').addClass('sticky');
      } else {
        $('.main_h').removeClass('sticky');
      }
    });

    $('.row_nav').click(function(event) {
      $('html, body').animate({
       scrollTop: 0
      }, 500);
    });
  }

  function init(){
    setupStickyHeaders();
  }

  return {
    init: init,
  }
}());

$(function(){
  Airbo.ScheduleDemoModal.init();
  Airbo.Utils.TextSelectionDetector.init("#link_for_copy", Airbo.ScheduleDemoModal.linkCopied);
  Airbo.PublicBoardManager.init();
});
